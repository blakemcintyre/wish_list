class CreateListPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :list_permissions do |t|
      t.references :list, foreign_key: true
      t.references :user, foreign_key: true
      # type? (edit/other)
      t.timestamps null: false

      t.index [:list_id, :user_id], unique: true
    end
  end
end
