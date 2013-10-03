class SunClassImportJob < Struct.new(:sheet)
  def perform()
    SunClass.import([])
  end
end