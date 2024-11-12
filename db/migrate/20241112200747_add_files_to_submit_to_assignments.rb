class AddFilesToSubmitToAssignments < ActiveRecord::Migration[7.2]
  def change
    add_column :assignments, :files_to_submit, :text
  end
end
