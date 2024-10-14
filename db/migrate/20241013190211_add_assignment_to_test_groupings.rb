class AddAssignmentToTestGroupings < ActiveRecord::Migration[7.2]
  def change
    add_reference :test_groupings, :assignment, null: false, foreign_key: true
  end
end
