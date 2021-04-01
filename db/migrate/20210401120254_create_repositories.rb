class CreateRepositories < ActiveRecord::Migration[6.1]
  def change
    create_table :repositories do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.belongs_to :github_installation, null: false, foreign_key: true
      t.string :name, null: false
      t.bigint :github_repository_id, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end
  end
end
