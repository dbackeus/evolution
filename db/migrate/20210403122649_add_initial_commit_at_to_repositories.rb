class AddInitialCommitAtToRepositories < ActiveRecord::Migration[6.1]
  def change
    add_column :repositories, :initial_commit_at, :datetime
  end
end
