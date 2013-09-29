class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :name
      t.hstore :preferences

      t.timestamps
    end
  end
end
