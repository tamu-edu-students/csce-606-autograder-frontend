FactoryBot.define do
  factory :permission do
    user { nil }
    assignment { nil }
    role { "MyString" }
  end
end
