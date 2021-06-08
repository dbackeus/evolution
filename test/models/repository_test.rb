require "test_helper"

class RepositoryTest < ActiveSupport::TestCase
  test "applies ON DELETE CASCADE to snapshots + dumps to avoid N+1 dependent: destroy performance bottleneck" do
    repository = repositories(:small)

    snapshots = repository.repository_snapshots
    tokei_dumps = snapshots.map(&:tokei_dump)

    repository.destroy

    refute RepositorySnapshot.where(id: snapshots.pluck(:id)).exists?
    refute RepositorySnapshotTokeiDump.where(id: tokei_dumps.pluck(:id)).exists?
  end
end
