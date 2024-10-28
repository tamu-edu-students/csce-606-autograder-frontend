class Test < ApplicationRecord
  belongs_to :assignment
  belongs_to :test_grouping

  acts_as_list scope: :test_grouping
  
  VALID_TEST_TYPES = [ "approved_includes", "compile", "coverage", "i/o", "memory_errors", "performance", "script", "style", "unit"  ]
  
  # Validations for required fields
  validates :test_block, presence: true
  validate :validate_test_block_keys
  validates :name, presence: { message: "Missing attribute: name" },  uniqueness: { scope: :assignment_id, message: "Test name must be unique" }
  validates :points, presence: { message: "Missing attribute: points" }, numericality: { greater_than: 0, message: "Points must be greater than 0" }

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

  def validate_test_block_keys
    return unless test_block.present?

    required_keys_by_type = {
      "approved_includes" => %w[approved_includes],
      "compile" => %w[file_paths],
      "coverage" => %w[source_paths main_path],
      "unit" => %w[code],
      "i/o" => %w[input_path output_path],
      "performance" => %w[code],
      "script" => %w[script_path],
      "memory_errors" => %w[file_paths]
    }

    required_keys = required_keys_by_type[test_type]

    if required_keys
      actual_keys = test_block.keys.map(&:to_s)

      unless actual_keys.sort == required_keys.sort
        errors.add(:test_block, "#{test_type} test must have attributes: #{required_keys.join(', ')}")
      end
    end
  end
end
