# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171121080047) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "documents", force: :cascade do |t|
    t.string "name"
    t.bigint "parent_folder_id"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_documents_on_created_by_id"
    t.index ["parent_folder_id"], name: "index_documents_on_parent_folder_id"
    t.index ["updated_by_id"], name: "index_documents_on_updated_by_id"
  end

  create_table "folders", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.bigint "parent_folder_id"
    t.index ["created_by_id"], name: "index_folders_on_created_by_id"
    t.index ["parent_folder_id"], name: "index_folders_on_parent_folder_id"
    t.index ["updated_by_id"], name: "index_folders_on_updated_by_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.string "name", default: "", null: false
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.integer "version"
    t.integer "size"
    t.bigint "document_id"
    t.bigint "user_id"
    t.boolean "current"
    t.string "upfile"
    t.datetime "expiration_date"
    t.datetime "created_at", null: false
    t.index ["document_id"], name: "index_versions_on_document_id"
    t.index ["user_id"], name: "index_versions_on_user_id"
  end

  add_foreign_key "documents", "folders", column: "parent_folder_id"
  add_foreign_key "documents", "users", column: "created_by_id"
  add_foreign_key "documents", "users", column: "updated_by_id"
  add_foreign_key "folders", "folders", column: "parent_folder_id"
  add_foreign_key "folders", "users", column: "created_by_id"
  add_foreign_key "folders", "users", column: "updated_by_id"
  add_foreign_key "versions", "documents"
  add_foreign_key "versions", "users"
end
