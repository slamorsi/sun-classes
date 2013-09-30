class RemoveClassIdFromPreferences < ActiveRecord::Migration
  def change
    remove_column :preferences, :class_id, :integer
  end
end
