class CreatePermissions < ActiveRecord::Migration[7.2]
  def change
    create_table :permissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :assignment, null: false, foreign_key: true
      t.string :role

      t.timestamps
    end
  end
end
