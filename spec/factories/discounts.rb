FactoryBot.define do
  factory :discount do
    association :merchant
    percentage { Faker::Number.number(digits: 2) }
    quantity { Faker::Number.between(from: 2, to: 5) }
  end
end
