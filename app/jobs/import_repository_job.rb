# Note: Importing and syncing will snapshot the latest commit for the current
# day. It should probably be changed to only work on "the previous day" to
# avoid snapshotting the current day which might be "in progress".

class ImportRepositoryJob < ApplicationJob
  queue_as :default

  VALID_PROGRESS_STATUSES = %w[importing syncing].freeze

  def perform(repository_id, in_progress_status = "importing")
    unless VALID_PROGRESS_STATUSES.include?(in_progress_status)
      raise ArgumentError, "in_progress_status must be one of #{VALID_PROGRESS_STATUSES} but was #{in_progress_status}"
    end

    repository = Repository.find(repository_id)

    Git.clone_repository(repository, "repository_imports") do |git|
      tokei = ENV["TOKEI_COMMAND"] || "tokei"

      initial_commit_at = Time.at(git.backtick("log --reverse --format=%ct | head -n 1").to_i)
      repository.update!(initial_commit_at: initial_commit_at, status: in_progress_status)

      current_date =
        if in_progress_status == "importing" && repository.repository_snapshots.any?
          # pick up where we left off in case import job aborted
          repository.repository_snapshots.minimum(:date)&.prev_day
        else
          # start from last commit date
          Time.at(git.backtick("log -1 --format=%ct").to_i).to_date
        end

      if in_progress_status == "syncing"
        last_sync_date = repository.repository_snapshots.maximum(:date)
      end

      loop do
        last_commit = git.backtick("rev-list -n 1 --before='#{current_date} 23:59:59' master")
        break if last_commit.empty? # we've gone past the initial commit

        git.run_or_raise "checkout #{last_commit}"

        current_commit_date = Time.at(git.backtick("log -1 --format=%ct").to_i).to_date
        break if in_progress_status == "syncing" && current_commit_date <= last_sync_date

        tokei_output = `#{tokei} -e /vendor/ -e /tmp/ -e /node_modules/ --output json #{git.clone_path}`
        tokei_output = tokei_output.gsub("#{git.clone_path}/", "") # remove clone path prefix from code file paths

        repository.repository_snapshots.create!(
          date: current_commit_date,
          repository_snapshot_tokei_dump: RepositorySnapshotTokeiDump.new(
            output: tokei_output,
          )
        )

        current_date = current_commit_date.prev_day

        GC.start # Avoid memory bloat while importing
      end

      repository.update!(status: "imported")
    end
  end
end
