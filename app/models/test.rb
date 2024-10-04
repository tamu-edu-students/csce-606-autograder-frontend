class Test < ApplicationRecord
  belongs_to :assignment
  validates :actual_test, presence: true
end
