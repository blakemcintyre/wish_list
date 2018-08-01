FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "user_#{i}@test.com" }
    sequence(:name) { |i| "User #{i}" }
    password "test1234"
  end
end
