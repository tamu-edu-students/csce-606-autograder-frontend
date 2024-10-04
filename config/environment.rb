# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

require_relative 'step_defs_helper'
World(StepDefsHelper)
