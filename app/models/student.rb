class Student < ActiveRecord::Base
  extend Importable
  has_many :class_assignments, :dependent => :destroy
  has_many :classes, :through => :class_assignments

  has_many :wait_list_assignment, :dependent => :destroy
  has_many :wait_list_classes, :class_name => SunClass, :through => :wait_list_assignment

  has_many :preferences, :dependent => :destroy 

  def full_name
    "#{self.first_name.present? ? self.first_name + " " : ""}#{self.last_name}"
  end

  def self.import(file)
    #last,  first,  hour, day         ,day2    ,etc
    #name,  name,   1,    pref1, pref2,
    #               2,    pref1, pref2,
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).step(2) do |i|
      #sets the last, first names
      names = Hash[[header[0..1].map{ |n| n.strip.downcase+'_name'}, spreadsheet.row(i)[0..1]].transpose]
      logger.debug "(#{i}) Student names: #{names}"

      parameters = ActionController::Parameters.new(names.to_hash)

      student = new
      student.attributes = parameters.permit(:first_name,:last_name)

      p1,p2 = nil
      hour_column = 3
      #starting at first day column
      (4..spreadsheet.last_column).each do |d|
        #header is 0 indexed array so -1
        day = header[d-1]
        logger.debug "(#{d-1}) day: #{day}"

        d2 = d

        #first preference for hour1 and hour2
        (i..i+1).each do |h| 
          next if (spreadsheet.empty?(h,d2))
          #hours will be in column 3
          hour = spreadsheet.cell(h,hour_column)
          logger.debug "(#{h},#{hour_column}) hour: #{hour}"
          logger.debug "(#{h},#{d2}) class: #{spreadsheet.cell(h,d2)}"
          sClass = SunClass.find_by_name(spreadsheet.cell(h,d2))
          logger.debug "Found class: #{sClass.to_json}"
          student.preferences.build order: d%2+1,day: day, hour: hour, sun_class: sClass if sClass
        end
      end

      student.save!
    end
  end
end
