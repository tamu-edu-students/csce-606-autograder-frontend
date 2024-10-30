FactoryBot.define do
  factory :assignment do
    sequence(:assignment_name) { |n| "Test Assignment #{n}" }
    sequence(:repository_name) { |n| "test-assignment-#{n}" }
  end
end