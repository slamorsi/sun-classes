class SunClassImportJob < Struct.new(:file)
  def perform
    SunClass.import(params[:file])
  end
end