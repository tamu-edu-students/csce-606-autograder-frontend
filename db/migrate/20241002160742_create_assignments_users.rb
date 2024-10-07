class CreateAssignmentsUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :assignments_users, id: false do |t|
      t.references :user, null: false, foreign_key: true
      t.references :assignment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
