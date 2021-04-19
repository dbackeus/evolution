class RepositoriesController < ApplicationController
  before_action :authenticate_user!

  def show
    @repository = current_account.repositories.find(params[:id])

    return unless @repository.status == "imported"

    if range = params[:range]
      from, to = range.split("..").map(&Date.method(:parse))
      @range = from..to
      scope = @repository.code_files.where(date: @range)
      range_distance_in_days = (to - from).to_i
      @frequency =
        case range_distance_in_days
          when ..31 then "day"
          when ..365 then "week"
          else "month"
        end
    else
      @frequency = "month"
      scope = @repository.code_files
    end

    latest_import = @repository.code_files.maximum(:date)
    @current_loc = @repository.code_files.where(date: latest_import).sum(:code)

    @significant_commits = Commit.most_significant(@repository.id, @frequency, @range)

    max_dates_per_frequency = scope
      .group("date_trunc('#{@frequency}', date)")
      .maximum(:date)
      .values

    @language_distribution = scope
      .where(date: max_dates_per_frequency)
      .group(:language, "toDate(date_trunc('#{@frequency}', date))")
      .order("todate_date_trunc_#{@frequency}_date")
      .sum(:code)
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
