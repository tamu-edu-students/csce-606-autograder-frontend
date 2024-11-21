class ChangeFilesToSubmitToAssignments < ActiveRecord::Migration[7.2]
  def change
    if ActiveRecord::Base.connection.adapter_name.downcase == 'sqlite'
      change_column :assignments, :files_to_submit, :jsonb, default: { "files_to_submit": [] }
    else
      change_column :assignments, :files_to_submit, :jsonb, using: 'files_to_submit::jsonb', default: { "files_to_submit": [] }
    end
  end
end
