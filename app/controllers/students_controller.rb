class StudentsController < ApplicationController

  def clear_all_assignments
    ClassAssignment.destroy_all
    WaitListAssignment.destroy_all
    redirect_to students_path, notice: "Student assignments cleared"
  end

  def assign_all
    Student.order('RANDOM()').includes(:sun_classes).includes(:wait_list_classes).includes(:preferences).references(:preferences, :sun_classes).each do |s|
      s.assign_class()
    end
    redirect_to students_path, notice: "Students assigned"
  end
  def import
    if params[:file]
      Student.import(params[:file])
      redirect_to students_path, notice: "Students imported."
    else
      redirect_to students_path, alert: "Missing file.", status: :unprocessable_entity
    end
  end

  def clear
    Student.destroy_all
    redirect_to students_path, notice: "Students cleared."
  end

  def index
    @students = Student.includes(:sun_classes).sorted_classes.includes(:wait_list_classes).sorted_wait_classes.includes(:preferences).sorted_preferences.references(:preferences, :sun_classes).order('students.last_name ASC').load
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
