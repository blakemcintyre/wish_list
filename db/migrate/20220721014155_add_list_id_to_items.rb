class AddListIdToItems < ActiveRecord::Migration[6.0]
  def change
    add_reference :items, :list, foreign_key: true, index: true
  end
end
