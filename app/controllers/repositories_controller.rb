class RepositoriesController < ApplicationController
  def show
    @repository = current_account.repositories.find(params[:id])
  end

  def create
    github_installation = current_account.github_installations.find(params[:github_installation_id])

    repository_response = Github.as_installation(github_installation).get("repositories/#{params[:github_repository_id]}")

    repository = current_account.repositories.create!(
      github_installation: github_installation,
      github_repository_id: repository_response.fetch("id"),
      name: repository_response.fetch("name"),
    )

    redirect_to repository
  end
end
