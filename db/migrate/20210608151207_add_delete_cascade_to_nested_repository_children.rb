class AddDeleteCascadeToNestedRepositoryChildren < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :repository_snapshots, :repositories
    add_foreign_key :repository_snapshots, :repositories, on_delete: :cascade

    remove_foreign_key :repository_snapshot_tokei_dumps, :repository_snapshots
    add_foreign_key :repository_snapshot_tokei_dumps, :repository_snapshots, on_delete: :cascade
  end
end
