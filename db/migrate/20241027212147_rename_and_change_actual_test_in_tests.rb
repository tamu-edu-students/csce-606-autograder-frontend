class RenameAndChangeActualTestInTests < ActiveRecord::Migration[7.2]
  def change
    rename_column :tests, :actual_test, :test_block, using: 'test_block::jsonb'
    change_column :tests, :test_block, :jsonb, default: {}
  end
end
