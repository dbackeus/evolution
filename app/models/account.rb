class Account < ApplicationRecord
  validates_presence_of :name

  has_many :code_files
  has_many :github_installations, dependent: :delete_all
  has_many :repositories, dependent: :destroy
  has_many :account_memberships, dependent: :delete_all
  has_many :users, through: :account_memberships

  after_destroy :delete_code_files

  private

  def delete_code_files
    CodeFile.connection.execute("ALTER TABLE code_files DELETE WHERE account_id = #{id}")
  end
end
