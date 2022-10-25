FactoryBot.define do
  factory :list do
    sequence(:name) { |i| "List #{i}" }

    permissions { [build(:list_permission, user: User.first || create(:user))] }
  end
end
