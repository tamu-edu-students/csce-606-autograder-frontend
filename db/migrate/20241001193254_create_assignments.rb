class CreateAssignments < ActiveRecord::Migration[7.2]
  def change
    create_table :assignments do |t|
      t.string 'assignment_name'
      t.string 'repository_name'
      t.string 'repository_url'
      t.timestamps
    end
  end
end
