class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.string :day
      t.integer :hour
      t.integer :class_id
      t.integer :student_id

      t.timestamps
    end
  end
end
