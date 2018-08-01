FactoryBot.define do
  factory :item do
    sequence(:name) { |i| "Item #{i}" }
  end
end
