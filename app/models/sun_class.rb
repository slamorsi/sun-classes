class SunClass < ActiveRecord::Base
  extend Importable
  has_many :class_alignments, :dependent => :destroy
  has_many :students, :through => :class_alignments

  has_many :wait_list_assignments, :dependent => :destroy
  has_many :wait_list_students, :class_name => Student, :through => :wait_list_assignments

  has_many :preferences, :dependent => :destroy

  scope :by_day, ->(day) {  where(day: day)}
  scope :by_hour, ->(hour) { where(hour: hour)}

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      sun_class = where(name: row["name"], day: row["day"], hour: row["hour"]).first || new
      parameters = ActionController::Parameters.new(row.to_hash)
      sun_class.attributes = parameters.permit(:name,:limit,:day, :hour)
      sun_class.save!
    end
  end
end
