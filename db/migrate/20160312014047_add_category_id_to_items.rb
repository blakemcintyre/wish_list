class AddCategoryIdToItems < ActiveRecord::Migration[4.2]
  def change
    add_reference :items, :category, index: true, foreign_key: true
  end
end
