class RenameNumberToPositionInTestsAndTestGroupingsTest < ActiveRecord::Migration[7.2]
  def up
    change_column :tests, :position, 'integer USING CASE WHEN position::text ~ E\'^\\d+$\' THEN position::integer ELSE 0 END'
    change_column :test_groupings, :position, 'integer USING CASE WHEN position::text ~ E\'^\\d+$\' THEN position::integer ELSE 0 END'
  end

  def down
    change_column :tests, :position, :string
    change_column :test_groupings, :position, :string
  end
end