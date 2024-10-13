class AddNotNullConstraintToTestGroupingIdInTests < ActiveRecord::Migration[7.2]
  def change
    change_column_null :tests, :test_grouping_id, false
  end
end
