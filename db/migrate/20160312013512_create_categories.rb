class CreateCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :categories do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name

      t.timestamps null: false
    end

    add_index :categories, [:user_id, :name], unique: true
  end
end
