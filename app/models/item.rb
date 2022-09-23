class Item < ActiveRecord::Base
  belongs_to :category
  belongs_to :list
  has_many :item_claims, dependent: :delete_all

  scope :claimed_with_quantity_sum, -> (list_id) {
    select("items.*, SUM(item_claims.quantity) AS claimed_qty")
      .undeleted
      .joins(:item_claims)
      .where(list_id: list_id)
      .group(*column_names)
  }
  scope :undeleted, -> { where(deleted_at: nil) }
  scope :recently_deleted, -> (limit_date = 1.week.ago) { where("deleted_at >= ?", limit_date) }

  # If the item hasn't been around for long then it's safe to just delete it
  def remove
    if created_at > 1.hour.ago && item_claims.empty?
      destroy
    else
      touch(:deleted_at)
    end
  end

  def claimed_quantity
    return 0 if quantity.nil?

    @claimed_quantity ||= ItemClaim.where(item_id: id).sum(:quantity)
  end
end
