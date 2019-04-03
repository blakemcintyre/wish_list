class CreateItemClaims < ActiveRecord::Migration[4.2]
  def change
    create_table :item_claims do |t|
      t.references :item
      t.references :user, index: true

      t.timestamps null: false
    end

    add_index :item_claims, :item_id, unique: true
  end
end
