class AddReasonToWaitListAssignments < ActiveRecord::Migration
  def change
    add_column :wait_list_assignments, :reason, :string
  end
end
