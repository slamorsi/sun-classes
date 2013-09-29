class CreateClassAssignments < ActiveRecord::Migration
  def change
    create_table :class_assignments do |t|
      t.integer :sun_class_id
      t.integer :student_id

      t.timestamps
    end
  end
end
