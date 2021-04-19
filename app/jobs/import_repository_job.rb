class ImportRepositoryJob < ApplicationJob
  queue_as :default

  def perform(repository_id)
    repository = Repository.find(repository_id)

    repository_import_path = "#{Rails.root}/tmp/repository_imports/#{repository.id}"
    FileUtils.rm_rf repository_import_path # delete leftovers from potentially failed attempt
    FileUtils.mkdir_p repository_import_path

    client = Github.as_installation(repository.github_installation)
    repository_response = client.get("repositories/#{repository.github_repository_id}")
    clone_url = "https://x-access-token:#{client.token}@github.com/#{repository_response.fetch('full_name')}.git"
    clone_path = "#{repository_import_path}/clone"

    system "git clone #{clone_url} #{clone_path}", exception: true

    tokei = ENV["TOKEI_COMMAND"] || "tokei"
    git_at_path = "git -C #{clone_path}"

    initial_commit_at = Time.at(`#{git_at_path} log --reverse --format=%ct | head -n 1`.to_i)
    repository.update!(initial_commit_at: initial_commit_at, status: "importing")

    current_date = repository.repository_snapshots.minimum(:date)&.prev_day || Time.at(`#{git_at_path} log -1 --format=%ct`.to_i).to_date
    loop do
      last_commit = `#{git_at_path} rev-list -n 1 --before="#{current_date} 23:59:59" master`
      break if last_commit.empty? # we've gone past the initial commit

      system "#{git_at_path} checkout #{last_commit}", exception: true

      current_commit_date = Time.at(`#{git_at_path} log -1 --format=%ct`.to_i).to_date
      tokei_output = `#{tokei} -e /vendor/ -e /tmp/ -e /node_modules/ --output json #{clone_path}`
      tokei_output = tokei_output.gsub("#{clone_path}/", "") # remove clone path prefix from code file paths

      repository.repository_snapshots.create!(
        date: current_commit_date,
        repository_snapshot_tokei_dump: RepositorySnapshotTokeiDump.new(
          output: tokei_output,
        )
      )

      current_date = current_commit_date.prev_day
    end

    repository.update!(status: "imported")
  end
end
