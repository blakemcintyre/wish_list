class ChangeUniqueKeyOnItemClaims < ActiveRecord::Migration[4.2]
  def up
    remove_index :item_claims, :item_id
    add_index :item_claims, %i[item_id user_id], unique: true
  end

  def down
    remove_index :item_claims, %i[item_id user_id]
    remove_index :item_claims, :item_id, unique: true
  end
end
