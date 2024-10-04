class Test < ApplicationRecord
  belongs_to :assignment
  validates :actual_test, presence: true
  has_one_attached :target
  validates :name, presence: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :test_type, presence: true
  validates :target, presence: true
end
