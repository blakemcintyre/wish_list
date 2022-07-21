namespace :temp do
  desc "Remove claimed items"
  task lists_migration: :environment do
    User.joins(:items)
      .having('COUNT(items.id) > 0')
      .group(:id)
      .each do |user|
        list = List.create!(name: user.name, permissions: [ListPermission.new(user: user)])
        user.items.update_all(list_id: list.id)
      end
  end
end
