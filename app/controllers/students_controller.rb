class StudentsController < ApplicationController

  def import
    if params[:file]
      Student.import(params[:file])
      redirect_to students_path, notice: "Classes imported."
    else
      redirect_to students_path, alert: "Missing file.", status: :unprocessable_entity
    end
  end

  def clear
    Student.destroy_all
    redirect_to students_path, notice: "Students cleared."
  end

  def index
    @students = Student.includes(:preferences).order('"preferences.hour" ASC', '"preferences.order" ASC').references(:preferences).load
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
end
