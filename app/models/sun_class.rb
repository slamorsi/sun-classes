class SunClass < ActiveRecord::Base
  extend Importable

  NON_DUPE_CLASSES = %w(ceramics)
  has_many :class_assignments, :dependent => :destroy
  has_many :students, :through => :class_assignments

  has_many :wait_list_assignments, :dependent => :destroy
  has_many :wait_list_students, :source => :student, :through => :wait_list_assignments

  has_many :preferences, :dependent => :destroy

  scope :by_day, ->(day) {  where(day: day)}
  scope :by_hour, ->(hour) { where(hour: hour)}
  scope :available, -> { where('"limit" > "class_assignments_count"')}

  validates_presence_of :name, :day, :hour, :limit

  def self.import(file)
    logger.debug "spreadsheet now"
    # logger.debug File.read(s)
    spreadsheet = open_spreadsheet(file)
    # logger.debug spreadsheet.to_csv
    allowed_params = :name,:limit,:day, :hour

    hour_col = 1
    header = spreadsheet.row(1).map{ |h| h.strip.downcase}
    (2..spreadsheet.last_column).step(2) do |ci|
      hi = ci-1
      (2..spreadsheet.last_row).each do |i|
        next if spreadsheet.empty?(i,ci)
        logger.debug "name: #{spreadsheet.cell(i,ci)}"
        logger.debug "ci: #{ci}, i:#{i}"
        logger.debug "hi: #{hi}, header: #{header}"
        logger.debug "row: #{spreadsheet.row(i)[hi..hi+1]}"
        row = Hash[[header[hi..hi+1], spreadsheet.row(i)[hi..hi+1]].transpose]
        #day columns are headed by the name of the day (column ci+1)
        row['day'] = header[hi]
        logger.debug "day: #{row['day']}"
        row['name'] = row[header[hi]]
        row['hour'] = spreadsheet.cell(i, hour_col)
        row.delete_if {|k,v| !k.in? allowed_params.map{|p| p.to_s}}

        sun_class = SunClass.where(name: row["name"], day: row["day"], hour: row["hour"]).first || SunClass.new
        parameters = ActionController::Parameters.new(row.to_hash)
        sun_class.attributes = parameters.permit(allowed_params)
        sun_class.save! 
      end
    end
    File.delete(file[:path])
  end

  def full?
    logger.debug "Class #{self.id} full?#{self.class_assignments_count >= self.limit}"
    self.class_assignments_count >= self.limit
  end
end
