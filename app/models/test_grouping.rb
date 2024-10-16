class TestGrouping < ApplicationRecord
  belongs_to :assignment
  has_many :tests

  after_destroy :reassign_tests_to_default_grouping

  private

  def reassign_tests_to_default_grouping
    default_grouping = assignment.test_groupings.find_by(name: "Miscellaneous Tests")
    # if deleted grouping is the default grouping, delete all tests
    if name == "Miscellaneous Tests"
      tests.destroy_all
      return
    end

    tests.update_all(test_grouping_id: default_grouping.id)
  end
end
