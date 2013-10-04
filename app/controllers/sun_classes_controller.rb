class SunClassesController < ApplicationController

  def import
    if params[:file]
      file_path = "#{Rails.root}/tmp/citemp#{DateTime.new.to_s}.csv"
      FileUtils.mv(params[:file].tempfile, file_path)
      SunClass.delay(:queue => 'classes_import').import(path: file_path, original_filename: params[:file].original_filename)

      redirect_to sun_classes_path, notice: "Classes are being imported, refresh page periodically to see updates"
    else
      redirect_to sun_classes_path, alert: "Missing file.", status: :unprocessable_entity
    end
  end

  def clear
    SunClass.destroy_all
    redirect_to sun_classes_path, notice: "Classes cleared."
  end

  def index
    @sClasses = SunClass.all
    @monClasses = @sClasses.by_day('mon')
    @tuesClasses = @sClasses.by_day('tues')
    @wedClasses = @sClasses.by_day('wed')
    @thursClasses = @sClasses.by_day('thurs')

    @monClasses_hour1 = @monClasses.by_hour(1)
    @tuesClasses_hour1 = @tuesClasses.by_hour(1)
    @wedClasses_hour1 = @wedClasses.by_hour(1)
    @thursClasses_hour1 = @thursClasses.by_hour(1)

    @monClasses_hour1_total = @monClasses_hour1.map {|c| c.class_assignments_count}.reduce(0, :+)
    @tuesClasses_hour1_total = @tuesClasses_hour1.map {|c| c.class_assignments_count}.reduce(0, :+)
    @wedClasses_hour1_total = @wedClasses_hour1.map {|c| c.class_assignments_count}.reduce(0, :+)
    @thursClasses_hour1_total = @wedClasses_hour1.map {|c| c.class_assignments_count}.reduce(0, :+)

    @monClasses_hour2 = @monClasses.by_hour(2)
    @tuesClasses_hour2 = @tuesClasses.by_hour(2)
    @wedClasses_hour2 = @wedClasses.by_hour(2)
    @thursClasses_hour2 = @thursClasses.by_hour(2)

    @monClasses_hour2_total = @monClasses_hour2.map {|c| c.class_assignments_count}.reduce(0, :+)
    @tuesClasses_hour2_total = @tuesClasses_hour2.map {|c| c.class_assignments_count}.reduce(0, :+)
    @wedClasses_hour2_total = @wedClasses_hour2.map {|c| c.class_assignments_count}.reduce(0, :+)
    @thursClasses_hour2_total = @wedClasses_hour2.map {|c| c.class_assignments_count}.reduce(0, :+)
  end

  def show
    @sun_class = SunClass.includes(:students, :wait_list_students, :class_assignments, :wait_list_assignments).references(:students, :wait_list_assignments, :class_assignments).find(params[:id])
  end

  def create
    @sun_class = SunClass.new sun_class_params
    if @sun_class.save
      redirect_to sun_class_path @sun_class, :notice => "#{@sun_class.name} created!"
    else
      render :action => 'new'
    end
  end

  def new
    @sun_class = SunClass.new
  end

  def update
    @sun_class = SunClass.find(params[:id])
    if @sun_class.update_attributes(sun_class_attributes)
      redirect_to sun_class_path @sun_class, :notice => "#{@sun_class.name} updated!"
    else
      render :action => 'edit'
    end
  end

  def edit
    @sun_class = SunClass.find(params[:id])
  end

  def destroy
    @sun_class = SunClass.find(params[:id])
    @sun_class.destroy
    redirect_to sun_classes_path
  end

  private

  def sun_class_params
    params.require(:sun_class).permit(:name, :limit, :day, :hour)
  end
end
