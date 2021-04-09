class ChartsController < ApplicationController
  before_action :authenticate_user!

  def index
    @charts = current_account.charts
  end

  def show
    @chart = current_account.charts.find(params[:id])

    @frequency = "month"
    scope = current_account.code_files
    scope = scope.where(repository_id: @chart.repositories.split(",")) if @chart.repositories

    # { [repo_id, "2016-06-01"] => Thu, 30 Jun 2016, [repo_id, "2007-03-01"] => Wed, 28 Mar 2007, ... }
    repos_max_dates_per_frequency = scope
      .group(:repository_id, "date_trunc('#{@frequency}', date)")
      .maximum(:date)

    repos_with_max_dates = Hash.new { |h, k| h[k] = [] }
    repos_max_dates_per_frequency.each do |(repository_id, date_trunc), date|
      repos_with_max_dates[repository_id] << date
    end

    interval_predicate = repos_with_max_dates.map do |repository_id, dates|
      query_friendly_dates = dates.map { |date| ApplicationRecord.connection.raw_connection.escape_literal(date.to_s) }.join(",")
      "repository_id = '#{repository_id}' AND date IN (#{query_friendly_dates})"
    end.join(" OR ")

    @chart_data = CodeFile
      .where(interval_predicate)
      .where(@chart.filters)
      .group(@chart.group_by || "repository_id", "toDate(date_trunc('#{@frequency}', date))") # toDate to avoid hours when frequency is day
      .order("todate_date_trunc_#{@frequency}_date")
      .sum(:code)

    render layout: false
  end

  def new
    @chart = current_account.charts.build
  end

  def create
    chart_params = params.require(:chart).permit(:name)
    @chart = current_account.charts.build(chart_params)

    if @chart.save
      redirect_to edit_chart_path(@chart)
    else
      render :new
    end
  end

  def edit
    @chart = current_account.charts.find(params[:id])
    @repository_names = current_account.repositories.pluck(:name)
  end

  def update
    chart_params = params.require(:chart).permit(:name, :group_by, :filters, repository_names: [])
    @chart = current_account.charts.find(params[:id])

    if @chart.update(chart_params)
      redirect_to edit_chart_path(@chart), notice: "Updated #{@chart.name}!"
    else
      @repository_names = current_account.repositories.pluck(:name)
      render :edit
    end
  end
end
