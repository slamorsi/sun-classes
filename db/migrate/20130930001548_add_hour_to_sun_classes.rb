class AddHourToSunClasses < ActiveRecord::Migration
  def change
    add_column :sun_classes, :hour, :integer
  end
end
