class CreateRepositorySnapshotTokeiDumps < ActiveRecord::Migration[6.1]
  def change
    create_table :repository_snapshot_tokei_dumps do |t|
      t.belongs_to :repository_snapshot, null: false, index: false, foreign_key: true
      t.text :output

      t.timestamps
    end

    add_index :repository_snapshot_tokei_dumps, :repository_snapshot_id, unique: true
  end
end
