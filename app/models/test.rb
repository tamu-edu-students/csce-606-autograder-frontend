class Test < ApplicationRecord
  belongs_to :assignment
  validates :actual_test, presence: true
  has_one_attached :target
  validates :name, presence: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :test_type, presence: true
  validates :target, presence: true
end
class Test < ApplicationRecord
  belongs_to :assignment
  validates :actual_test, presence: true


  # Validations for required fields
  validates :name, presence: { message: 'Missing attribute: name' },  uniqueness: { scope: :assignment_id, message: "Test name must be unique" }
  validates :points, presence: { message: 'Missing attribute: points'}, numericality: true

  VALID_TEST_TYPES = ['approved_includes', 'compile', 'coverage', 'i/o', 'memory_errors', 'performance', 'script', 'style', 'unit'  ]
  validates :test_type, presence: { message: 'Missing attribute: type'}, inclusion: { in: VALID_TEST_TYPES, message: "Unknown test type: %{value}" }
  
  validates :target, presence: { message: 'Missing attribute: target' }, unless: -> { %w[compile memory_errors script style].include?(test_type) }
  # Optional attributes with defaults
  attribute :show_output, :boolean, default: false
  attribute :skip, :boolean, default: false
  attribute :timeout, :float, default: 10
  attribute :visibility, :string, default: 'visible'
end
