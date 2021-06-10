class ImportCommitsJob < ApplicationJob
  queue_as :default

  def perform(repository_id)
    @repository = Repository.find(repository_id)

    Git.clone_repository(@repository, "commit_imports") do |git|
      @now = Time.now
      commit_attributes = []

      # Example of typical commit:
      # c234f16ff902c36f270d3224b2960dcbd58ff6e2 1503312319 My commit message
      #
      #  24 files changed, 152 insertions(+), 65 deletions(-)
      #
      # Example with no deletions:
      # 4efcbc5d1e961f72d380ec6f19281957272b1873 1374749206 Fix viewing a character while logged out.
      #
      #  1 file changed, 15 insertions(+)
      #
      # Example without changes:
      # e0916b8772c5a5c980cb4aed0a7f48961d8bbffb 1441731902 Upgrading to Cedar-14

      git.popen('log -c --shortstat --first-parent --format="commit %H %ct %s"') do |stdout|
        three_line_buffer = []
        stdout.each do |line|
          # Reset the buffer if we start a new commit, this bypasses commits without changes
          # where we end up with 2 consecutive "commit" lines.
          three_line_buffer.clear if line.start_with?("commit")

          three_line_buffer << line

          if three_line_buffer.length == 3
            commit_attributes << git_log_to_commit_attributes(three_line_buffer)
            three_line_buffer.clear
          end
        end
      end

      Commit.transaction do
        @repository.commits.delete_all
        Commit.insert_all(commit_attributes)
      end
    end
  end

  private

  def git_log_to_commit_attributes(three_lines)
    formatted, _blank, shortstat = three_lines
    sha, timestamp, subject = formatted.match(/commit (.{40}) (\d+) (.*)/).captures
    files_changed = shortstat.match(/(\d+) file/)&.captures&.first.to_i
    insertions = shortstat.match(/(\d+) insertion/)&.captures&.first.to_i
    deletions = shortstat.match(/(\d+) deletion/)&.captures&.first.to_i

    {
      repository_id: @repository.id,
      sha: sha,
      subject: subject,
      files_changed: files_changed,
      insertions: insertions,
      deletions: deletions,
      net_diff: insertions - deletions,
      commited_at: Time.at(timestamp.to_i),
      created_at: @now,
      updated_at: @now,
    }
  end
end
