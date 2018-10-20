FactoryBot.define do
  factory :item do
    category
    user
    sequence(:name) { |i| "Item #{i}" }
  end
end
