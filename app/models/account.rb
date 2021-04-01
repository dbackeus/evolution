class Account < ApplicationRecord
  validates_presence_of :name

  has_many :github_installations
end
