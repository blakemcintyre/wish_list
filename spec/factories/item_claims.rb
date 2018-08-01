FactoryBot.define do
  factory :item_claim do
    association :item
    association :user
  end
end
