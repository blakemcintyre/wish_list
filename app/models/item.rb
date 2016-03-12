class Item < ActiveRecord::Base
  belongs_to :user
  has_one :item_claim

  scope :claimed, -> { includes(:item_claim).references(:item_claim).where('item_claims.id IS NOT NULL OR items.deleted_at IS NOT NULL') }
  scope :unclaimed, -> { includes(:item_claim).references(:item_claim).where(item_claims: { id: nil }).undeleted }
  scope :undeleted, -> { where(deleted_at: nil) }
end
