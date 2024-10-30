FactoryBot.define do
    factory :test_grouping do
      association :assignment
  
      sequence(:name) { |n| "Test Group #{n}" }
  
      # Add a trait for creating a test grouping with associated tests
      trait :with_tests do
        transient do
          tests_count { 3 }
        end
  
        after(:create) do |test_grouping, evaluator|
          create_list(:test, evaluator.tests_count, test_grouping: test_grouping, assignment: test_grouping.assignment)
        end
      end
    end
  end