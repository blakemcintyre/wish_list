class AddParentCatgoryIdToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :parent_category_id, :integer
    add_index :categories, :parent_category_id
  end
end
