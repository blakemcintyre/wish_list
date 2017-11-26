class AddQuantityToItemClaims < ActiveRecord::Migration
  def change
    add_column :item_claims, :quantity, :integer, default: 1, null: false
  end
end
