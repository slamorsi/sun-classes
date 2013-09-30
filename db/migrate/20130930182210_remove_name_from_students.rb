class RemoveNameFromStudents < ActiveRecord::Migration
  def change
    remove_column :students, :name, :string
  end
end
