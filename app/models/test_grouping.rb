class TestGrouping < ApplicationRecord
  belongs_to :assignment
  has_many :tests, dependent: :destroy

  acts_as_list scope: :assignment

  validates :name, presence: { message: "Test grouping name can't be blank" }
  validates :name, uniqueness: { scope: :assignment_id, message: "A test case grouping with this name already exists" }
end
