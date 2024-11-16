class RenameNumberToPositionInTestsAndTestGroupingsTest < ActiveRecord::Migration[7.2]
  def change
    change_column :tests, :position, :integer, using: 'position::integer'
    change_column :test_groupings, :position, :integer, using: 'position::integer'
  end
end
