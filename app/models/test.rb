class Test < ApplicationRecord
    belongs_to :assignment
  
    after_create :regenerate_tests_file
    after_update :regenerate_tests_file
    after_destroy :regenerate_tests_file
  
    private
  
    def regenerate_tests_file
      assignment.generate_tests_file
    end
  end
  