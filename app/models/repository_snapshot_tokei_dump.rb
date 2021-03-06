# Note: don't rely on destroy callbacks since model entries are deleted via
# foreign key delete cascade

class RepositorySnapshotTokeiDump < ApplicationRecord
  belongs_to :repository_snapshot

  validates_presence_of :output

  after_commit :enqueue_ingest_job, on: :create

  private

  def enqueue_ingest_job
    IngestTokeiDumpJob.perform_later(id)
  end
end
