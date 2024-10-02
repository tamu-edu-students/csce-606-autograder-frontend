class Test < ApplicationRecord
  belongs_to :assignment

  # Validations for required fields
  validates :name, presence: true
  validates :points, presence: true, numericality: true
  validates :type, presence: true, inclusion: { in: %w[approved_includes compile coverage i/o memory_errors performance script style unit] }
  validates :target, presence: true, unless: -> { %w[compile memory_errors script style].include?(type) }

  # Optional attributes with defaults
  attribute :show_output, :boolean, default: false
  attribute :skip, :boolean, default: false
  attribute :timeout, :float, default: 10
  attribute :visibility, :string, default: 'visible'

  # Example scope for sorting by @number
  scope :sorted, -> { order(:number) }
end

