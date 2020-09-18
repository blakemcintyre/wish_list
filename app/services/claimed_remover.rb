class ClaimedRemover
  def initialize(user)
    @user = user
  end

  def process
    process_claims
    remove_soft_deleted
  end

  private

  def process_claims
    Item.claimed_with_quantity_sum(@user.id).each do |item|
      next item.destroy if item.claimed_qty >= item.quantity

      partially_claimed(item)
    end
  end

  def partially_claimed(item)
    Item.transaction do
      item.update(quantity: item.quantity - item.claimed_qty)
      item.item_claims.delete_all
    end
  end

  def remove_soft_deleted
    @user.items.where.not(deleted_at: nil).destroy_all
  end
end
