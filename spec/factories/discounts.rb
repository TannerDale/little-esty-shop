FactoryBot.define do
  factory :discount do
    percentage { 1 }
    quantity { 1 }
    merchant { nil }
  end
end
