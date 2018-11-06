class AddClaimAcknowledgedToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :claim_acknowledged, :boolean, default: false
  end
end
