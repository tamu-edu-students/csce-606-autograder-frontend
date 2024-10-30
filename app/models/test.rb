class Test < ApplicationRecord
  belongs_to :assignment
  belongs_to :test_grouping

  acts_as_list scope: :test_grouping

  VALID_TEST_TYPES = [ "approved_includes", "compile", "coverage", "i_o", "memory_errors", "performance", "script", "unit"  ]

  # Validations for required fields
  validates :test_block, presence: true
  validate :validate_test_block_keys
  validates :name, presence: { message: "Missing attribute: name" },  uniqueness: { scope: :assignment_id, message: "Test name must be unique" }
  validates :points, presence: { message: "Missing attribute: points" }, numericality: { greater_than: 0, message: "Points must be greater than 0" }

  validates :test_type, presence: { message: "Missing attribute: type" }, inclusion: { in: VALID_TEST_TYPES, message: "Unknown test type: %{value}" }

  validates :target, presence: { message: "Missing attribute: target" }, unless: -> { %w[compile memory_errors script ].include?(test_type) }
  # Optional attributes with defaults
  attribute :show_output, :boolean, default: false
  attribute :skip, :boolean, default: false
  attribute :timeout, :float
  attribute :visibility, :string, default: "visible"

  before_validation :set_default_test_grouping, on: :create

  def regenerate_tests_file
    assignment.generate_tests_file
  end

  # TODO: move test string construction
  # from `Assignment` to `Test`. Define in to_s method.

  def get_test_block_string
    case test_type
    when "approved_includes"
      # newline-delimited list of approved includes with prepended tabs
      test_block["approved_includes"].map { |approved_include| "\t#{approved_include}" }.join("\n")
    when "compile", "memory_errors"
      # newline-delimited list of file paths with prepended tabs
      test_block["file_paths"].map { |file_path| "\t#{file_path}" }.join("\n")
    when "coverage"
      # space-delimited list of source paths followed by main path with prepended tabs
      "\tsource: #{test_block["source_paths"].join(' ')}\n" \
      "\tmain: #{test_block["main_path"]}"
    when "unit", "performance"
      # code block with prepended tabs on each line
      test_block["code"].split("\n").map { |line| "\t#{line}" }.join("\n")
    when "i_o"
      # input and output paths with prepended tabs
      "\tinput: #{test_block["input_path"]}\n" \
      "\toutput: #{test_block["output_path"]}"
    when "script"
      # script path with prepended tab
      "\t#{test_block["script_path"]}"
    else
      raise "Unknown test type: #{test_type}"
    end
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
      "i_o" => %w[input_path output_path],
      "performance" => %w[code],
      "script" => %w[script_path],
      "memory_errors" => %w[file_paths]
    }

    required_keys = required_keys_by_type[test_type]

    if required_keys
      actual_keys = test_block.keys.map(&:to_s)

      unless actual_keys.sort == required_keys.sort
        errors.add(:test_block, "#{test_type} test must have attribute(s): #{required_keys.join(', ')}")
      end
    end
  end
end
