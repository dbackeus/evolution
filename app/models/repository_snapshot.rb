# Note: don't rely on destroy callbacks since model entries are deleted via
# foreign key delete cascade

class RepositorySnapshot < ApplicationRecord
  belongs_to :repository

  has_one :repository_snapshot_tokei_dump # dependent: delete via foreign key
  alias :tokei_dump :repository_snapshot_tokei_dump
end
