class RenameAndChangeActualTestInTests < ActiveRecord::Migration[7.2]
  def change
    rename_column :tests, :actual_test, :test_block
    if ActiveRecord::Base.connection.adapter_name.downcase == 'sqlite'
      change_column :tests, :test_block, :jsonb, default: {}
    else
      change_column :tests, :test_block, :jsonb, using: 'test_block::jsonb', default: {}
    end
  end
end
