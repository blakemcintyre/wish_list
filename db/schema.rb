# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_07_21_014155) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "parent_category_id"
    t.index ["parent_category_id"], name: "index_categories_on_parent_category_id"
    t.index ["user_id", "name"], name: "index_categories_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "item_claims", id: :serial, force: :cascade do |t|
    t.integer "item_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity", default: 1, null: false
    t.string "notes"
    t.index ["item_id", "user_id"], name: "index_item_claims_on_item_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_item_claims_on_user_id"
  end

  create_table "items", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "category_id"
    t.integer "quantity", default: 1
    t.bigint "list_id"
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["list_id"], name: "index_items_on_list_id"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "list_permissions", force: :cascade do |t|
    t.bigint "list_id", null: false
    t.bigint "user_id", null: false
    t.boolean "claimable", default: false
    t.index ["list_id"], name: "index_list_permissions_on_list_id"
    t.index ["user_id"], name: "index_list_permissions_on_user_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "name", null: false
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "categories", "users"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "lists"
  add_foreign_key "list_permissions", "lists"
  add_foreign_key "list_permissions", "users"
end
