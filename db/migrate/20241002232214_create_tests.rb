class CreateTests < ActiveRecord::Migration[7.2]
  def change
    create_table :tests do |t|
      t.string :name
      t.float :points
      t.string :type
      t.string :target
      t.text :include
      t.string :number
      t.boolean :show_output
      t.boolean :skip
      t.float :timeout
      t.string :visibility
      t.references :assignment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
