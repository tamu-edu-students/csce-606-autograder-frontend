class ChangeFilesToSubmitToAssignments < ActiveRecord::Migration[7.2]
  def change
    change_column :assignments, :files_to_submit, :jsonb, default: { "files_to_submit": [] }
  end
end
