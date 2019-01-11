class CreateLists < ActiveRecord::Migration[5.2]
  def change
    create_table :lists do |t|
      t.string :name, null: false
      t.references :creator, foreign_key: { to_table: :users }
      t.timestamps null: false
    end
  end
end
