class AddGoogleDomainToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :google_domain, :string

    add_index :accounts, :google_domain, unique: true, where: "google_domain IS NOT NULL"
  end
end
