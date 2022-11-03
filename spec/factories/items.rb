FactoryBot.define do
  factory :item do
    category
    list
    sequence(:name) { |i| "Item #{i}" }
  end
end
