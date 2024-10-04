class RenameTypeColumnInTests < ActiveRecord::Migration[7.2]
  def change
    rename_column :tests, :type, :test_type
  end
end
