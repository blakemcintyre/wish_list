class CreateListPermissions < ActiveRecord::Migration[6.0]
  def change
    create_table :list_permissions do |t|
      t.references :list, null: false, index: true, foreign_key: true
      t.references :user, null: false, index: true, foreign_key: true
      t.boolean :claimable, default: false
    end
  end
end
