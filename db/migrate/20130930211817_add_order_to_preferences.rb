class AddOrderToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :order, :integer
  end
end
