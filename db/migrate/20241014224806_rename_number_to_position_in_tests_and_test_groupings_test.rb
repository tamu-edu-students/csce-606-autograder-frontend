class RenameNumberToPositionInTestsAndTestGroupingsTest < ActiveRecord::Migration[7.2]
  def change
    if ActiveRecord::Base.connection.adapter_name.downcase == 'sqlite'
      change_column :tests, :position, :integer
      change_column :test_groupings, :position, :integer
    else
      change_column :tests, :position, :integer, using: 'position::integer'
      change_column :test_groupings, :position, :integer, using: 'position::integer'
    end
  end
end
