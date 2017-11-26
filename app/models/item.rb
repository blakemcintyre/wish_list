class Item < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  has_many :item_claims

  scope :undeleted, -> { where(deleted_at: nil) }
  scope :recently_deleted, -> (limit_date = 1.week.ago) { where("deleted_at >= ?", limit_date) }

  # If the item hasn't been around for long then it's safe to just delete it
  def remove
    if created_at > 1.hour.ago && item_claims.empty?
      destroy
    else
      update_attributes(deleted_at: Time.zone.now)
    end
  end

  def claimed_quantity
    return 0 if quantity.nil?

    @claimed_quantity ||= ItemClaim.where(item_id: id).sum(:quantity)
  end

  def self.claimed_grouping(item_user_id, claim_user_id)
    item_ids = { claimed: [], unclaimed: [] }
    excluded_ids = ItemClaim.joins(:item)
      .where(user_id: claim_user_id, items: { user_id: item_user_id })
      .merge(Item.undeleted)
      .pluck(:item_id)

    select("items.id, items.quantity, SUM(COALESCE(item_claims.quantity, 0)) AS claimed")
      .joins("LEFT JOIN item_claims ON items.id = item_claims.item_id")
      .where(user_id: item_user_id)
      .undeleted
      .group(:id)
      .each do |item|
        item_ids[:unclaimed] << item.id if item.quantity.nil? || (item.claimed < item.quantity && !excluded_ids.include?(item.id))
        item_ids[:claimed] << item.id if item.quantity.present? && item.claimed > 0
      end

    item_ids
  end
end
