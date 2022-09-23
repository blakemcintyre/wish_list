FactoryBot.define do
  factory :category do
    association :list
    sequence(:name) { |i| "Category #{i}" }
  end
end
