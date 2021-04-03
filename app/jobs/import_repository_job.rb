class ImportRepositoryJob < ApplicationJob
  SUCCESS = "💪".freeze

  queue_as :default

  def perform(repository_id)
    repository = Repository.find(repository_id)

    repository_import_path = "#{Rails.root}/tmp/repository_imports/#{repository_id}"
    FileUtils.rm_rf repository_import_path # delete leftovers from potentially failed attempt
    FileUtils.mkdir_p repository_import_path

    client = Github.as_installation(repository.github_installation)
    repository_response = client.get("repositories/#{repository.github_repository_id}")
    clone_url = "https://x-access-token:#{client.token}@github.com/#{repository_response.fetch('full_name')}.git"
    clone_path = "#{repository_import_path}/clone"

    system "git clone #{clone_url} #{clone_path}", exception: true

    # Fork to avoid thread unsafety issues with Dir.chdir
    readio, writeio = IO.pipe
    pid = fork do
      readio.close
      Dir.chdir(clone_path) do
        initial_commit_at = Time.at(`git log --reverse --format=%ct | head -n 1`.to_i)
        repository.update!(initial_commit_at: initial_commit_at, status: "importing")

        current_date = repository.repository_snapshots.minimum(:date).prev_day || Time.at(`git log -1 --format=%ct`.to_i).to_date
        loop do
          last_commit = `git rev-list -n 1 --before="#{current_date} 23:59:59" master`
          break if last_commit.empty? # we've gone past the initial commit

          system "git checkout #{last_commit}", exception: true

          current_commit_date = Time.at(`git log -1 --format=%ct`.to_i).to_date
          tokei_output = `tokei -e /vendor/ -e /tmp/ -e /node_modules/ --output json`

          repository.repository_snapshots.create!(
            date: current_commit_date,
            repository_snapshot_tokei_dump: RepositorySnapshotTokeiDump.new(
              output: tokei_output,
            )
          )

          current_date = current_commit_date.prev_day
        end
      end
      writeio.write SUCCESS
    rescue => e
      error_json = { class: e.class.to_s, message: e.message, backtrace: e.backtrace }.to_json
      writeio.write error_json
    ensure
      exit!(0) # skip at_exit handler
    end

    writeio.close
    output = readio.read
    Process.wait(pid)
    raise "Child failed with unknown error" if output.empty?

    if output == SUCCESS
      repository.update!(status: "imported")
    else
      error = JSON.parse(output)
      recreated_exception = error["class"].constantize.new(error["message"]) rescue nil
      if recreated_exception
        recreated_exception.set_backtrace(error.fetch("backtrace"))
        raise recreated_exception
      else
        raise output # fall back to JSON string in case we failed to recreate
      end
    end
  end
end
