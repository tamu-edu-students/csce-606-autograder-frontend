class ChangeIncludeInTests < ActiveRecord::Migration[6.0]
  def up
    remove_column :tests, :include
    add_column :tests, :include, :string, array: true
  end

  def down
    remove_column :tests, :include
    add_column :tests, :include, :text
  end
end

