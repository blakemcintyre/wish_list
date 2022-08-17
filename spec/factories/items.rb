FactoryBot.define do
  factory :item do
    category
    user
    list
    sequence(:name) { |i| "Item #{i}" }
  end
end
