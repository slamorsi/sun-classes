class SunClass < ActiveRecord::Base
  extend Importable

  NON_DUPE_CLASSES = %w(Spanish, Chess, Zumba, Ceramics)
  has_many :class_assignments, :dependent => :destroy
  has_many :students, :through => :class_assignments

  has_many :wait_list_assignments, :dependent => :destroy
  has_many :wait_list_students, :class_name => Student, :through => :wait_list_assignments

  has_many :preferences, :dependent => :destroy

  scope :by_day, ->(day) {  where(day: day)}
  scope :by_hour, ->(hour) { where(hour: hour)}

  def self.import(file)
    allowed_params = :name,:limit,:day, :hour
    spreadsheet = open_spreadsheet(file)

    header = spreadsheet.row(1)
    (0..spreadsheet.last_column).step(3) do |ci|
      (2..spreadsheet.last_row).each do |i|
        header = header[ci..ci+2].map{ |h| h.strip.downcase}
        row = Hash[[header, spreadsheet.row(i)[ci..ci+2]].transpose]
        #day columns are headed by the name of the day (column ci+1)
        row['day'] = header[ci+1]
        row['name'] = row[header[ci+1]]
        row.delete_if {|k,v| !k.in? allowed_params.map{|p| p.to_s}}

        sun_class = where(name: row["name"], day: row["day"], hour: row["hour"]).first || new
        parameters = ActionController::Parameters.new(row.to_hash)
        sun_class.attributes = parameters.permit(allowed_params)
        sun_class.save! 
      end
    end
  end

  def full?
    logger.debug "Class #{self.id} full?#{self.class_assignments_count >= self.limit}"
    self.class_assignments_count >= self.limit
  end
end
