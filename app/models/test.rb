class Test < ApplicationRecord
  belongs_to :assignment
  belongs_to :test_grouping
  validates :actual_test, presence: true


  # Validations for required fields
  validates :name, presence: { message: "Missing attribute: name" },  uniqueness: { scope: :assignment_id, message: "Test name must be unique" }
  validates :points, presence: { message: "Missing attribute: points" }, numericality: { greater_than: 0, message: "Points must be greater than 0" }

  VALID_TEST_TYPES = [ "approved_includes", "compile", "coverage", "i/o", "memory_errors", "performance", "script", "style", "unit"  ]
  validates :test_type, presence: { message: "Missing attribute: type" }, inclusion: { in: VALID_TEST_TYPES, message: "Unknown test type: %{value}" }

  validates :target, presence: { message: "Missing attribute: target" }, unless: -> { %w[compile memory_errors script style].include?(test_type) }
  # Optional attributes with defaults
  attribute :show_output, :boolean, default: false
  attribute :skip, :boolean, default: false
  attribute :timeout, :float
  attribute :visibility, :string, default: "visible"

  before_validation :set_default_test_grouping, on: :create

  def regenerate_tests_file
    assignment.generate_tests_file
  end

  private

  def set_default_test_grouping
    self.test_grouping ||= TestGrouping.find_by(name: "Miscellaneous Tests")
  end
end
