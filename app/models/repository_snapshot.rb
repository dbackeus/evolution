class RepositorySnapshot < ApplicationRecord
  belongs_to :repository

  has_one :repository_snapshot_tokei_dump, dependent: :delete
end
