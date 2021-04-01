class CreateGithubInstallations < ActiveRecord::Migration[6.1]
  def change
    create_table :github_installations do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.bigint :installation_id, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :github_installations, :installation_id, unique: true
  end
end
