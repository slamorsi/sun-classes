class AssignStudentsJob 
  def perform()
    Student.order('RANDOM()').includes(:sun_classes).includes(:wait_list_classes).includes(:preferences).references(:preferences, :sun_classes).each do |s|
      s.assign_class()
    end
  end
end