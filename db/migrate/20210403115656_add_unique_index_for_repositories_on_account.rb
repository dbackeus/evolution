class AddUniqueIndexForRepositoriesOnAccount < ActiveRecord::Migration[6.1]
  def change
    add_index :repositories, [:account_id, :github_repository_id], unique: true
  end
end
