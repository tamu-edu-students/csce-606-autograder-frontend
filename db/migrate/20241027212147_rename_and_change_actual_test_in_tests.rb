class RenameAndChangeActualTestInTests < ActiveRecord::Migration[7.2]
  def change
    rename_column :tests, :test_block, :test_block
    change_column :tests, :test_block, :jsonb, default: {}
  end
end
