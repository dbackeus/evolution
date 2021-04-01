class GithubInstallation < ApplicationRecord
  belongs_to :account

  validates_presence_of :installation_id
  validates_presence_of :name
end
