class AddNotesToItemClaims < ActiveRecord::Migration[6.0]
  def change
    add_column :item_claims, :notes, :string
  end
end
