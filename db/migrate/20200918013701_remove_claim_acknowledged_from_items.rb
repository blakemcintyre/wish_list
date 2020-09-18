require_relative '20181106014913_add_claim_acknowledged_to_items'

class RemoveClaimAcknowledgedFromItems < ActiveRecord::Migration[6.0]
  def change
    revert AddClaimAcknowledgedToItems
  end
end
