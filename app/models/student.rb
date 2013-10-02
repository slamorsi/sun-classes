class Student < ActiveRecord::Base
  extend Importable
  has_many :class_assignments, :dependent => :destroy
  has_many :sun_classes, :through => :class_assignments

  has_many :wait_list_assignments, :dependent => :destroy
  has_many :wait_list_classes, :source => :sun_class, :through => :wait_list_assignments

  has_many :preferences, :dependent => :destroy 

  scope :sorted_preferences, -> {order("case when preferences.day='mon' then 1 when preferences.day='tues' then 2 when preferences.day='wed' then 3 when preferences.day='thurs' then 4 else 5 end ASC,preferences.hour ASC,'preferences.order' ASC")}

  scope :sorted_classes, -> {order("case when sun_classes.day='mon' then 1 when sun_classes.day='tues' then 2 when sun_classes.day='wed' then 3 when sun_classes.day='thurs' then 4 else 5 end ASC,sun_classes.hour ASC,'sun_classes.order' ASC")}

  scope :sorted_wait_classes, -> {order("case when sun_classes.day='mon' then 1 when sun_classes.day='tues' then 2 when sun_classes.day='wed' then 3 when sun_classes.day='thurs' then 4 else 5 end ASC,sun_classes.hour ASC,'sun_classes.order' ASC")}

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
        #student must find spot in both hours so build instead of create assignments and save if both hours were filled

        #skip if student already has assigned class for this day and hour or if they have a class with same name on a different day or hour but they are in the non-dupe list
        if !assigned.find {|a| already_assigned = (a.day == day and a.hour == hour) or a.name.in?(SunClass::NON_DUPE_CLASSES)}.nil?
          hours_to_fill =-1 if already_assigned
          next
        end
        logger.debug "Choosing class for day: #{day} hour: #{hour}"
        wanted_pref1 = preferences.find {|p| p.day == day and p.hour == hour and p.order ==1 }
        next if wanted_pref1.nil?
        logger.debug "Found preference: #{wanted_pref1.to_json}"
        wanted = wanted_pref1.sun_class
        if wanted.full?
          wanted_pref2 = preferences.find {|p| p.day == day and p.hour == hour and p.order ==2 }
          if wanted_pref2.nil?
            logger.debug "Creating waiting list assignment for first"
            self.wait_list_assignment.find_or_create_by :sun_class => wanted, :preference => 1, :reason => WaitListAssignment::REASONS[:full]
          else 
            logger.debug "Found preference: #{wanted2.to_json}"
            wanted2 = wanted_pref2.sun_class
            if wanted2.full?
              logger.debug "Creating waiting list assignment for both"
              self.wait_list_assignment.find_or_create_by :sun_class => wanted2, :preference => 2, :reason => WaitListAssignment::REASONS[:full]
              self.wait_list_assignment.find_or_create_by :sun_class => wanted, :preference => 1, :reason => WaitListAssignment::REASONS[:full]
            else
              logger.debug "Creating assignment for second"
              pending_pref = wanted_pref2
              pending_assignment = self.class_assignments.where(sun_class_id: wanted2.id).first || self.class_assignments.build(sun_class: wanted2)

              hours_to_fill -= 1
            end
          end
        else
          logger.debug "Creating assignment for first"
          pending_pref = wanted_pref1
          pending_assignment = self.class_assignments.where(sun_class_id: wanted.id).first || self.class_assignments.build(sun_class: wanted)

          hours_to_fill -= 1
        end
      end

      #Save pending class assignments if both hours were filled
      if hours_to_fill == 0
        self.save!
      elsif hours_to_fill == 1
        #otherwise we know they only found a class for one hour and we insert that class into wait list assignment
        pending_assignment.delete

        self.wait_list_assignment.find_or_create_by :sun_class => pending_pref.sun_class, :preference => pending_pref.order, :reason => WaitListAssignment::REASONS[:invalid_hours] 
      end
    end
  end

  def self.import(file)
    #last,  first,  hour, day         ,day2    ,etc
    #name,  name,   1,    pref1, pref2,
    #               2,    pref1, pref2,
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).step(2) do |i|
      #sets the last, first names
      names = Hash[[header[0..1].map{ |n| n.strip.downcase+'_name'}, spreadsheet.row(i)[0..1].map{|n| n.strip if n}].transpose]
      logger.debug "(#{i}) Student names: #{names}"

      parameters = ActionController::Parameters.new(names.to_hash)

      student = new
      student.attributes = parameters.permit(:first_name,:last_name)

      p1,p2 = nil
      hour_column = 3
      #starting at first day column
      (4..spreadsheet.last_column).each do |d|
        #header is 0 indexed array so -1
        day = header[d-1].downcase
        logger.debug "(#{d-1}) day: #{day}"

        d2 = d

        #first preference for hour1 and hour2
        (i..i+1).each do |h| 
          next if (spreadsheet.empty?(h,d2))
          #hours will be in column 3
          hour = spreadsheet.cell(h,hour_column)
          logger.debug "(#{h},#{hour_column}) hour: #{hour}"
          logger.debug "(#{h},#{d2}) class: #{spreadsheet.cell(h,d2)}"
          sClass = SunClass.find_by_name_and_hour_and_day(spreadsheet.cell(h,d2), hour, day)
          logger.debug "Found class: #{sClass.to_json}"
          student.preferences.build order: d%2+1,day: day, hour: hour, sun_class: sClass if sClass
        end
      end

      student.save!
    end
  end
end
