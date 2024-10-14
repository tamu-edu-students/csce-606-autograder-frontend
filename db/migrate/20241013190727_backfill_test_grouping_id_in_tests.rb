class BackfillTestGroupingIdInTests < ActiveRecord::Migration[7.2]
  def up
    Assignment.find_each do |assignment|
      default_grouping = assignment.test_groupings.create!(name: "Miscellaneous Tests")
      assignment.tests.update_all(test_grouping_id: default_grouping.id)
    end
  end
end
