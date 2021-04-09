# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# clickhouse:schema:load`. When creating a new database, `rails clickhouse:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ClickhouseActiverecord::Schema.define(version: 2021_03_30_134908) do

  # TABLE: code_files
  # SQL: CREATE TABLE evolution_development.code_files ( `account_id` Int64, `repository_id` Int64, `date` Date, `path` String, `language` String, `blanks` UInt32, `code` UInt32, `comments` UInt32, `lines` UInt32, `created_at` Nullable(DateTime) DEFAULT NULL ) ENGINE = MergeTree ORDER BY (account_id, date, repository_id) SETTINGS index_granularity = 8192
  create_table "code_files", id: false, options: "MergeTree ORDER BY (account_id, date, repository_id) SETTINGS index_granularity = 8192", force: :cascade do |t|
    t.integer "account_id", unsigned: false, limit: 8, null: false
    t.integer "repository_id", unsigned: false, limit: 8, null: false
    t.date "date", null: false
    t.string "path", null: false
    t.string "language", null: false
    t.integer "blanks", null: false
    t.integer "code", null: false
    t.integer "comments", null: false
    t.integer "lines", null: false
    t.datetime "created_at"
  end

end
