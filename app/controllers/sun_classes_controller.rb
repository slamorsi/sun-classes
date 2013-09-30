class SunClassesController < ApplicationController

  def import
    if params[:file]
      SunClass.import(params[:file])
      redirect_to sun_classes_path, notice: "Classes imported."
    else
      render action: "index", error: "Missing file."
    end
  end

  def clear
    SunClass.destroy_all
    redirect_to sun_classes_path, notice: "Classes cleared."
  end

  def index
    @sClasses = SunClass.all
    @monClasses = @sClasses.by_day('Mon')
    @tuesClasses = @sClasses.by_day('Tues')
    @wedClasses = @sClasses.by_day('Wed')
    @thursClasses = @sClasses.by_day('Thurs')

    @monClasses_hour1 = @monClasses.by_hour(1)
    @tuesClasses_hour1 = @tuesClasses.by_hour(1)
    @wedClasses_hour1 = @wedClasses.by_hour(1)
    @thursClasses_hour1 = @thursClasses.by_hour(1)

    @monClasses_hour2 = @monClasses.by_hour(2)
    @tuesClasses_hour2 = @tuesClasses.by_hour(2)
    @wedClasses_hour2 = @wedClasses.by_hour(2)
    @thursClasses_hour2 = @thursClasses.by_hour(2)
  end

  def show
  end

  def create
  end

  def new
  end

  def update
  end

  def edit
  end

  def destroy
  end

  private

  def person_params
    params.require(:sun_class).permit(:name, :limit, :day, :hour)
  end
end
