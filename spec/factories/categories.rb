FactoryBot.define do
  factory :category do
    association :user
    sequence(:name) { |i| "Category #{i}" }
  end
end
