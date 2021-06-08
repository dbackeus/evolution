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

ActiveRecord::Schema.define(version: 2021_06_08_151207) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_account_memberships_on_account_id"
    t.index ["user_id"], name: "index_account_memberships_on_user_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "google_domain"
    t.index ["google_domain"], name: "index_accounts_on_google_domain", unique: true, where: "(google_domain IS NOT NULL)"
  end

  create_table "charts", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name", null: false
    t.string "group_by"
    t.string "repositories"
    t.string "filters"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "filter_ids", default: [], null: false, array: true
    t.date "start_date"
    t.index ["account_id"], name: "index_charts_on_account_id"
  end

  create_table "commits", force: :cascade do |t|
    t.bigint "repository_id", null: false
    t.string "sha", null: false
    t.string "subject"
    t.integer "files_changed", null: false
    t.integer "insertions", null: false
    t.integer "deletions", null: false
    t.integer "net_diff", null: false
    t.datetime "commited_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["repository_id"], name: "index_commits_on_repository_id"
  end

  create_table "filters", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name", null: false
    t.text "sql", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_filters_on_account_id"
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

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "remember_token"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "account_memberships", "accounts"
  add_foreign_key "account_memberships", "users"
  add_foreign_key "charts", "accounts"
  add_foreign_key "commits", "repositories"
  add_foreign_key "filters", "accounts"
  add_foreign_key "github_installations", "accounts"
  add_foreign_key "repositories", "accounts"
  add_foreign_key "repositories", "github_installations"
  add_foreign_key "repository_snapshot_tokei_dumps", "repository_snapshots", on_delete: :cascade
  add_foreign_key "repository_snapshots", "repositories", on_delete: :cascade
end
