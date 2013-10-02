class AddClassAssignmentsCountAndWaitListAssignmentsCountToSunClasses < ActiveRecord::Migration
  def change
    add_column :sun_classes, :class_assignments_count, :integer, :null => false, :default => 0
    add_column :sun_classes, :wait_list_assignments_count, :integer, :null => false, :default => 0

    SunClass.all.each do |c|
      SunClass.reset_counters(c.id, :class_assignments)
      SunClass.reset_counters(c.id, :wait_list_assignments)
    end
  end
end
