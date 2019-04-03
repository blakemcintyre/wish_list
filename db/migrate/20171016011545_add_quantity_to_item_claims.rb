class AddQuantityToItemClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :item_claims, :quantity, :integer, default: 1, null: false
  end
end
