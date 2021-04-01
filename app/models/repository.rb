class Repository < ApplicationRecord
  belongs_to :account
  belongs_to :github_installation

  validates_presence_of :name
  validates_presence_of :github_repository_id
  validates_inclusion_of :status, in: %w[pending]
end
