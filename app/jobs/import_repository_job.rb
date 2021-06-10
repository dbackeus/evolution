class ImportRepositoryJob < ApplicationJob
  queue_as :default

  def perform(repository_id)
    repository = Repository.find(repository_id)

    Git.clone_repository(repository, "repository_imports") do |git|
      tokei = ENV["TOKEI_COMMAND"] || "tokei"

      initial_commit_at = Time.at(git.backtick("log --reverse --format=%ct | head -n 1").to_i)
      repository.update!(initial_commit_at: initial_commit_at, status: "importing")

      current_date =
        if repository.repository_snapshots.any?
          repository.repository_snapshots.minimum(:date).prev_day
        else
          Time.at(git.backtick("log -1 --format=%ct").to_i).to_date
        end

      loop do
        last_commit = git.backtick("rev-list -n 1 --before='#{current_date} 23:59:59' master")
        break if last_commit.empty? # we've gone past the initial commit

        git.run_or_raise "checkout #{last_commit}"

        current_commit_date = Time.at(git.backtick("log -1 --format=%ct").to_i).to_date
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
