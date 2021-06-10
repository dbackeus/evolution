class DailyRepositorySyncJob < ApplicationJob
  def perform
    Repository.
      where(status: "imported").
      includes(:github_installation).
      joins("JOIN commits ON commits.id = (SELECT id FROM commits WHERE repository_id = repositories.id ORDER BY commited_at DESC LIMIT 1)").
      select("repositories.*, commits.commited_at as last_imported_commit_at")
      .find_each do |repository|
        github_client = Github.as_installation(repository.github_installation)
        last_commits = github_client.get("repositories/#{repository.github_repository_id}/commits?per_page=1")
        last_commit_at = Time.parse(last_commits.first.fetch("commit").fetch("committer").fetch("date"))

        if last_commit_at > repository.last_imported_commit_at
          ImportRepositoryJob.perform_later(repository.id, "syncing")
          ImportCommitsJob.perform_later(repository.id)
        end
      end
  end
end
