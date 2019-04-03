class AddDeletedAtToItems < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :deleted_at, :datetime
  end
end
