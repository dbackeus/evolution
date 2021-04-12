class CommitsController < ApplicationController
  def show
    commit = Commit.find(params[:id])
    github_repo = commit.repository.repository_at_github
    repo_url = github_repo.fetch("html_url")

    redirect_to "#{repo_url}/commit/#{commit.sha}"
  end
end
