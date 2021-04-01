# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_01_120254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "github_installations", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "installation_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_github_installations_on_account_id"
    t.index ["installation_id"], name: "index_github_installations_on_installation_id", unique: true
  end

  create_table "repositories", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "github_installation_id", null: false
    t.string "name", null: false
    t.bigint "github_repository_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_repositories_on_account_id"
    t.index ["github_installation_id"], name: "index_repositories_on_github_installation_id"
  end

  add_foreign_key "github_installations", "accounts"
  add_foreign_key "repositories", "accounts"
  add_foreign_key "repositories", "github_installations"
end
