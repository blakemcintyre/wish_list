class AddListIdToCategories < ActiveRecord::Migration[6.0]
  def change
    add_reference :categories, :list, foreign_key: true, index: true
  end
end
