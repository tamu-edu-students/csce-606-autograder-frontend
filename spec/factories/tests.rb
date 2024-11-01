# spec/factories/tests.rb
FactoryBot.define do
    factory :test do
      association :assignment  # Ensures each test is associated with an assignment
      name { "Sample Test" }
      points { 10 }
      test_type { "unit" }
      position { 1 }
      test_block { { "code" => "Sample code block" } }
      target { "sample_target.cpp" }
      # Add any other necessary attributes and associations here
    end
  end
