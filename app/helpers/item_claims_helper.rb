module ItemClaimsHelper
  def max_claimable_quantity(item, claim = nil)
    return if item.quantity.nil?

    quantity = item.quantity - item.claimed_quantity
    quantity += claim.quantity if claim.present?
    quantity
  end
end
