class AddTestGroupingToTests < ActiveRecord::Migration[7.2]
  def change
    add_reference :tests, :test_grouping, foreign_key: true
  end
end
