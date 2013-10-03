class Student < ActiveRecord::Base
  extend Importable
  has_many :class_assignments, :dependent => :destroy, :after_add => :class_assignment_added
  has_many :sun_classes, :through => :class_assignments

  has_many :wait_list_assignments, :dependent => :destroy
  has_many :wait_list_classes, :source => :sun_class, :through => :wait_list_assignments

  has_many :preferences, :dependent => :destroy 

  validates_presence_of :first_name, :last_name, :student_id

  scope :sorted_preferences, -> {
    order("preferences.hour ASC,'preferences.order' ASC")

  }

  scope :sorted_classes, -> {
    order("sun_classes.hour ASC,'sun_classes.order' ASC")
  }

  scope :sorted_wait_classes, -> {
    order("sun_classes.hour ASC,'sun_classes.order' ASC")
  }

  def full_name
    "#{self.first_name.present? ? self.first_name + " " : ""}#{self.last_name}"
  end

  def assign_class()
    #First we want to check preferences in order for each hour. If preference 1 is full, check as potential wait list class, if preference 2 is full then we add both as wait list classes. On wait list check, we'll go per hour's wait list classes in preference order and place student in the open one while removing both wait classes
    preferences = self.preferences.to_a
    assigned = self.sun_classes.to_a

    return if preferences.empty? or assigned.length == 4

    logger.debug "Classes already assigned: #{assigned.to_a}"

    ["mon","tues","wed","thurs"].each do |day|
      hours_to_fill = 2
      pending_pref = nil
      pending_assignment = nil
      [1,2].each do |hour| 
        wanted = nil
        wanted2 = nil
        #student must find spot in both hours so build instead of create assignments and save if both hours were filled
        logger.debug "Choosing class for day: #{day} hour: #{hour}"

        #skip if student already has assigned class for this day and hour
        if isAlreadyAssigned?(assigned, day, hour)
          hours_to_fill -= 1
          next
        end

        pending_pref1 = processPreference(1,day, hour, preferences, assigned)
        #if first pref is open then pend assignment and continue
        if pending_pref1 and !pending_pref1.sun_class.full?
          pending_pref = pending_pref1
          pending_assignment = self.class_assignments.where(sun_class_id: pending_pref1.sun_class.id).first || self.class_assignments.build(sun_class: pending_pref1.sun_class)

          hours_to_fill -= 1
          next
        end

        #otherwise process 2nd preference

        pending_pref2 = processPreference(2,day, hour, preferences, assigned)

        #if there is no 2nd preference, wait list first pref and continue
        if !pending_pref2
          self.wait_list_assignments.find_or_create_by :sun_class => pending_pref1.sun_class, :preference => 1, :reason => WaitListAssignment::REASONS[:full] if pending_pref1
          next
        end

        #if 2nd preference is also full, wait list both
        if pending_pref2.sun_class.full?
          logger.debug "Creating waiting list assignment for both"
          self.wait_list_assignments.find_or_create_by :sun_class => pending_pref2.sun_class, :preference => 2, :reason => WaitListAssignment::REASONS[:full]
          self.wait_list_assignments.find_or_create_by :sun_class => pending_pref.sun_class, :preference => 1, :reason => WaitListAssignment::REASONS[:full]
        #otherwise pend assignment for 2nd preference
        else
          logger.debug "Creating assignment for second"
          pending_pref = pending_pref2
          pending_assignment = self.class_assignments.where(sun_class_id: pending_pref2.sun_class.id).first || self.class_assignments.build(sun_class: pending_pref2.sun_class)

          hours_to_fill -= 1
        end
      end

      #Save pending class assignments if both hours were filled
      logger.debug "Hours to fill: #{hours_to_fill}"
      if hours_to_fill == 0
        self.save!
      elsif hours_to_fill == 1
        #otherwise we know they only found a class for one hour and we insert that class into wait list assignment
        pending_assignment.delete

        self.wait_list_assignments.find_or_create_by :sun_class => pending_pref.sun_class, :preference => pending_pref.order, :reason => WaitListAssignment::REASONS[:invalid_hours] 
      end
    end
  end

  def self.import(file)
    #last,  first,  student id, hour, day         ,day2    ,etc
    #name,  name,               1,    pref1, pref2,
    #                           2,    pref1, pref2,
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).step(2) do |i|
      #sets the last, first names
      names = Hash[[header[0..1].map{ |n| n.strip.downcase+'_name'}, spreadsheet.row(i)[0..1].map{|n| n.strip if n}].transpose]
      logger.debug "(#{i}) Student names: #{names}"

      parameters = ActionController::Parameters.new(names.to_hash.merge(student_id: spreadsheet.row(i)[2]))

      attributes = parameters.permit(:first_name,:last_name, :student_id)

      if attributes[:student_id]
        student = find_by_student_id(attributes[:student_id]) || new(attributes)
      else 
        student = new attributes
      end

      p1,p2 = nil
      hour_column = 4
      #starting at first day column
      (5..spreadsheet.last_column).each do |d|
        #header is 0 indexed array so -1
        day = header[d-1].downcase
        logger.debug "(#{d-1}) day: #{day}"

        d2 = d

        (i..i+1).each do |h| 
          next if (spreadsheet.empty?(h,d2))
          #hours will be in column 3
          hour = spreadsheet.cell(h,hour_column)
          logger.debug "(#{h},#{hour_column}) hour: #{hour}"
          logger.debug "(#{h},#{d2}) class: #{spreadsheet.cell(h,d2)}"
          sClass = SunClass.find_by_name_and_hour_and_day(spreadsheet.cell(h,d2), hour, day)
          logger.debug "Found class: #{sClass.to_json}"
          if sClass
            previousPreference = student.preferences.find_by_sun_class_id(sClass.id)

            if previousPreference.nil?
              student.preferences.build order: (d-1)%2+1,day: day, hour: hour, sun_class: sClass
            else
              if !(previousPreference.order == d%2 and previousPreference.day == day and previousPreference.hour == hour)
                previousPreference.update_attributes(order: d%2,day: day, hour: hour)
              end
            end
          end
        end
      end

      student.save!
    end
  end

  def isInDupeClass?(assignedList, name)
    !(assignedList.find {|a| (a.name.downcase == name.downcase and a.name.downcase.in?(SunClass::NON_DUPE_CLASSES))}.nil?)
  end

  def isAlreadyAssigned?(assignedList, day, hour)
    !(assignedList.find {|a| (a.day == day and a.hour == hour)}.nil?)
  end

  private

  def processPreference(order, day, hour, preferences, assignedList)
    wanted_pref = preferences.find {|p| p.day == day and p.hour == hour and p.order == order }
    #skip if they have a class with same name on a different day or hour but they are in the non-dupe list
    return nil if !wanted_pref || isInDupeClass?(assignedList, wanted_pref.sun_class.name)
    return wanted_pref
  end

  def class_assignment_added(c)
    #Delete any wait list assignments for same class
    self.wait_list_assignments.where(:sun_class_id => c.sun_class.id).each {|a| a.destroy}
  end
end
