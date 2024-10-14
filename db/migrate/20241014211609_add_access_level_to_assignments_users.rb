class AddAccessLevelToAssignmentsUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :assignments_users, :access_level, :string
    add_index :assignments_users, [:user_id, :assignment_id], unique: true
  end
end
