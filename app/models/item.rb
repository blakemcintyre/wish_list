class Item < ActiveRecord::Base
  belongs_to :user
  has_one :item_claim

  acts_as_list scope: :user

  scope :claimed, -> { includes(:item_claim).references(:item_claim).where.not(item_claims: { id: nil }) }
  scope :unclaimed, -> { joins('LEFT JOIN item_claims ON items.id = item_claims.item_id').where('item_claims.id IS NULL') }
end
