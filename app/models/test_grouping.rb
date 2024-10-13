class TestGrouping < ApplicationRecord
  belongs_to :assignment
  has_many :tests
end
