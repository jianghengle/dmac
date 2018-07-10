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

ActiveRecord::Schema.define(version: 20180710161810) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "channels", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "path"
    t.string   "meta_data"
    t.text     "instruction"
    t.boolean  "rename"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "files"
    t.string   "status"
    t.string   "name"
    t.string   "file_filter"
    t.index ["project_id"], name: "index_channels_on_project_id", using: :btree
  end

  create_table "controls", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "email"
    t.string   "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "group_name"
    t.index ["email"], name: "index_controls_on_email", using: :btree
    t.index ["project_id"], name: "index_controls_on_project_id", using: :btree
  end

  create_table "downloads", force: :cascade do |t|
    t.string   "key"
    t.string   "project_key"
    t.string   "data_path"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["key"], name: "index_downloads_on_key", using: :btree
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "status"
    t.string   "key"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "path"
    t.string   "meta_data"
    t.boolean  "auto_history"
    t.index ["key"], name: "index_projects_on_key", unique: true, using: :btree
    t.index ["status"], name: "index_projects_on_status", using: :btree
  end

  create_table "publics", force: :cascade do |t|
    t.string   "key"
    t.integer  "project_id"
    t.string   "data_path"
    t.string   "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_publics_on_key", unique: true, using: :btree
    t.index ["path"], name: "index_publics_on_path", using: :btree
    t.index ["project_id"], name: "index_publics_on_project_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "role"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "auth_token"
    t.string   "username"
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "channels", "projects"
  add_foreign_key "controls", "projects"
  add_foreign_key "publics", "projects"
end
