class TestGrouping < ApplicationRecord
  belongs_to :assignment
  has_many :tests, dependent: :destroy

  acts_as_list scope: :assignment
end
