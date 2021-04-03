class CreateRepositorySnapshots < ActiveRecord::Migration[6.1]
  def change
    create_table :repository_snapshots do |t|
      t.belongs_to :repository, null: false, foreign_key: true
      t.date :date, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :repository_snapshots, [:repository_id, :date], unique: true
  end
end
