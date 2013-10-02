class AddPreferenceToWaitListAssignment < ActiveRecord::Migration
  def change
    add_column :wait_list_assignments, :preference, :integer
  end
end
