FactoryBot.define do
  factory :category do
    association :user
    association :list
    sequence(:name) { |i| "Category #{i}" }
  end
end
