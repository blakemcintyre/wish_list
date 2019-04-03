class CreateItems < ActiveRecord::Migration[4.2]
  def change
    create_table :items do |t|
      t.references :user, index: true
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
