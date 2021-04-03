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

ActiveRecord::Schema.define(version: 2021_04_03_122649) do

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
    t.datetime "initial_commit_at"
    t.index ["account_id", "github_repository_id"], name: "index_repositories_on_account_id_and_github_repository_id", unique: true
    t.index ["account_id"], name: "index_repositories_on_account_id"
    t.index ["github_installation_id"], name: "index_repositories_on_github_installation_id"
  end

  create_table "repository_snapshot_tokei_dumps", force: :cascade do |t|
    t.bigint "repository_snapshot_id", null: false
    t.text "output"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["repository_snapshot_id"], name: "index_repository_snapshot_tokei_dumps_on_repository_snapshot_id", unique: true
  end

  create_table "repository_snapshots", force: :cascade do |t|
    t.bigint "repository_id", null: false
    t.date "date", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["repository_id", "date"], name: "index_repository_snapshots_on_repository_id_and_date", unique: true
    t.index ["repository_id"], name: "index_repository_snapshots_on_repository_id"
  end

  add_foreign_key "github_installations", "accounts"
  add_foreign_key "repositories", "accounts"
  add_foreign_key "repositories", "github_installations"
  add_foreign_key "repository_snapshot_tokei_dumps", "repository_snapshots"
  add_foreign_key "repository_snapshots", "repositories"
end
