class Item < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  has_one :item_claim

  scope :claimed, -> { includes(:item_claim).references(:item_claim).where.not(item_claims: { id: nil }).undeleted }
  scope :unclaimed, -> { includes(:item_claim).references(:item_claim).where(item_claims: { id: nil }).undeleted }
  scope :undeleted, -> { where(deleted_at: nil) }
  scope :recently_deleted, -> (limit_date = 1.week.ago) { where("deleted_at >= ?", limit_date) }

  # If the item hasn't been around for long then it's safe to just delete it
  def remove
    if created_at > 1.hour.ago && item_claim.blank?
      destroy
    else
      update_attributes(deleted_at: Time.zone.now)
    end
  end
end
