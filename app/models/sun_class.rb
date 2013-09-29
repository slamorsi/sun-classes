class SunClass < ActiveRecord::Base
  has_many :class_alignments
  has_many :students, :through => :class_alignments

  has_many :wait_list_assignments
  has_many :wait_list_students, :class_name => Student, :through => :wait_list_assignments

  has_many :preferences

  # scope :by_day, -> {group(:day)}

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      sun_class = find_by_id(row["id"]) || new
      parameters = ActionController::Parameters.new(row.to_hash)
      sun_class.attributes = parameters.permit(:name,:limit,:day)
      sun_class.save!
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    when ".ods" then Roo::OpenOffice.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end


end
