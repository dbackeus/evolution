class CreateCommits < ActiveRecord::Migration[6.1]
  def change
    create_table :commits do |t|
      t.belongs_to :repository, null: false, foreign_key: true
      t.string :sha, null: false
      t.string :subject
      t.integer :files_changed, null: false
      t.integer :insertions, null: false
      t.integer :deletions, null: false
      t.integer :net_diff, null: false
      t.datetime :commited_at, null: false

      t.timestamps
    end
  end
end
