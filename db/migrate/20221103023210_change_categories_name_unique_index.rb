class ChangeCategoriesNameUniqueIndex < ActiveRecord::Migration[6.0]
  def up
    remove_index :categories, %i(user_id name)
    add_index :categories, %i(list_id name), unique: true
  end

  def down
    remove_index :categories, %i(list_id name)
    add_index :categories, %i(user_id name), unique: true
  end
end
