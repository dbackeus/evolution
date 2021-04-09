class RepositoriesController < ApplicationController
  def show
    @repository = current_account.repositories.find(params[:id])

    if @repository.status == "imported"
      latest_import = @repository.code_files.maximum(:date)
      @current_loc = @repository.code_files.where(date: latest_import).sum(:code)

      @frequency = "day"
      @language_distribution = @repository
        .code_files
        .group(:language, "toDate(date_trunc('#{@frequency}', date))")
        .order("todate_date_trunc_#{@frequency}_date")
        .sum(:code)
    end
  end

  def index
    @repositories = current_account.repositories
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
