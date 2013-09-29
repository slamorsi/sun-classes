class CreateWaitListAssignments < ActiveRecord::Migration
  def change
    create_table :wait_list_assignments do |t|
      t.integer :sun_class_id
      t.integer :student_id

      t.timestamps
    end
  end
end
