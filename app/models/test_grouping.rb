class TestGrouping < ApplicationRecord
  belongs_to :assignment
  has_many :tests
  
  acts_as_list scope: :assignment

  validates :name, presence: { message: "Test grouping name can't be blank" }
  validates :name, uniqueness: { scope: :assignment_id, message: "A test case grouping with this name already exists" }

  after_destroy :reassign_tests_to_default_grouping

  private

  def reassign_tests_to_default_grouping
    default_grouping = assignment.test_groupings.find_by(name: "Miscellaneous Tests")
    # if deleted grouping is the default grouping, delete all tests
    if name == "Miscellaneous Tests"
      tests.destroy_all
      nil
    end

    if !default_grouping.nil?
      tests.update_all(test_grouping_id: default_grouping.id)
    end
  end
end
