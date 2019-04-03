class AddDeletedAtToCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :deleted_at, :timestamp
  end
end
