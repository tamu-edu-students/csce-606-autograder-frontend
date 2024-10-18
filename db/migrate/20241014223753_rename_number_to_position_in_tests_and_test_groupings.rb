class RenameNumberToPositionInTestsAndTestGroupings < ActiveRecord::Migration[7.2]
  def change
    rename_column :tests, :number, :position
    rename_column :test_groupings, :number, :position
  end
end
