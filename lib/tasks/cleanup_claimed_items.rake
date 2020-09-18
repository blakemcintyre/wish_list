namespace :cleanup_claimed_items do
  desc "Remove claimed items"
  task run: :environment do
    User.find_each do |user|
      ClaimedRemover.new(user).process
    end
  end
end
