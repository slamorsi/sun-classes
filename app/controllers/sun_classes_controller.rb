class SunClassesController < ApplicationController

  def import
    SunClass.import(params[:file])
    redirect_to sun_classes_path, notice: "Classes imported."
  end

  def index
    @sClasses = SunClass.all
    @monClasses = @sClasses.where(:day => 'Mon')
    @tuesClasses = @sClasses.where(:day => 'Tues')
    @wedClasses = @sClasses.where(:day => 'Wed')
    @thursClasses = @sClasses.where(:day => 'Thurs')

    @maxNumClasses = [@monClasses.length, @tuesClasses.length, @wedClasses.length, @thursClasses.length].max
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
    params.require(:sun_class).permit(:name, :limit, :day)
  end
end
