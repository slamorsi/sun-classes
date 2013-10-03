class StudentsController < ApplicationController

  def clear_all_assignments
    ClassAssignment.destroy_all
    WaitListAssignment.destroy_all
    redirect_to students_path, notice: "Student assignments cleared"
  end

  def unassign
    @student = Student.find(params[:id])

    @student.class_assignments.where(:sun_class_id => params[:sun_class_id]).destroy_all

    redirect_to student_path(@student), :notice => "Student removed from class."
  end

  def assign
    @student = Student.find(params[:id])
    @sun_class = SunClass.find(params[:sun_class_id])

    if !@sun_class.full?
      isAlreadyAssigned = @student.sun_classes.where(id: @sun_class.id)
      if isAlreadyAssigned.empty?
        if @student.isInDupeClass?(@student.sun_classes,@sun_class.name)
          return redirect_to student_path(@student), :alert => "Could not add to #{@sun_class.name} because student is already taking this non-duplicable class another time"
        end
        @student.class_assignments.create :sun_class => @sun_class
        redirect_to student_path(@student), :notice => "Student assigned to: #{@sun_class.name}"
      else
        redirect_to student_path(@student), :alert => "Student was already assigned to: #{@sun_class.name}"
      end
    else
      redirect_to student_path(@student), :alert => "#{@sun_class.name} is full!"
    end
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
    @students = Student.includes(:sun_classes).sorted_classes.includes(:wait_list_classes).sorted_wait_classes.includes(:preferences).sorted_preferences.includes(:wait_list_assignments).references(:preferences, :sun_classes, :wait_list_assignments).order('students.last_name ASC').load
  end

  def show
    @student = Student.includes(:sun_classes, :wait_list_classes, :class_assignments, :wait_list_assignments).references(:sun_classes, :class_assignments, :wait_list_assignments).find(params[:id])

    @available_classes = SunClass.available
  end

  def create
    @student = Student.new student_params
    if @student.save
      redirect_to student_path @student, :notice => "#{@student.name} created!"
    else
      render :action => 'new'
    end
  end

  def new
    @student = Student.new
  end

  def update
    @student = Student.find(params[:id])
    if @student.update_attributes(student_attributes)
      redirect_to student_path @student, :notice => "#{@student.name} updated!"
    else
      render :action => 'edit'
    end
  end

  def edit
    @student = Student.find(params[:id])
  end

  def destroy
    @student = Student.find(params[:id])
    @student.destroy
    redirect_to studentes_path
  end

  private

  def student_params
    params.require(:student).permit(:first_name, :last_name)
  end
end
