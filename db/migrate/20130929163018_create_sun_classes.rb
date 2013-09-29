class CreateSunClasses < ActiveRecord::Migration
  def change
    create_table :sun_classes do |t|
      t.string :name
      t.integer :limit
      t.string :day

      t.timestamps
    end
  end
end
