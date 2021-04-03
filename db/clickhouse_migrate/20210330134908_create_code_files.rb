class CreateCodeFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :code_files, id: false, options: "MergeTree() ORDER BY (account_id, date, repository_id)" do |t|
      t.bigint :account_id, null: false
      t.bigint :repository_id, null: false
      t.date :date, null: false
      t.string :path, null: false
      t.string :language, null: false
      t.integer :blanks, null: false
      t.integer :code, null: false
      t.integer :comments, null: false
      t.integer :lines, null: false
      t.datetime :created_at, default: "now()"
    end
  end
end
