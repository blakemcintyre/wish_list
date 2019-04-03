class AddQuanityToItems < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :quantity, :integer, default: 1
  end
end
