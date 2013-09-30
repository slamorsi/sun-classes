class AddSunClassIdToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :sun_class_id, :integer
  end
end
