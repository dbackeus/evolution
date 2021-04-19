class ChartsController < ApplicationController
  before_action :authenticate_user!

  def index
    @charts = current_account.charts
  end

  def show
    @chart = current_account.charts.find(params[:id])

    @frequency = "month"
    scope = current_account.code_files
    scope = scope.where(date: @chart.start_date..) if @chart.start_date
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

    filters = current_account.filters.find(@chart.filter_ids)

    # { [label1, trunced_date1] => sum, [label1, trunced_date2] => sum, [label2, trunced_date1] => sum, ... }
    @chart_data =
      if @chart.group_by == "filters"
        filters.each_with_object({}) do |filter, data_by_filter_name_and_date|
          current_account.code_files
            .where(interval_predicate)
            .where(@chart.filters)
            .where(filter.sql)
            .group("toDate(date_trunc('#{@frequency}', date))")
            .order("todate_date_trunc_#{@frequency}_date")
            .sum(:code)
            .each { |date, sum| data_by_filter_name_and_date[[filter.name, date]] = sum }
        end
      else
        CodeFile
          .where(interval_predicate)
          .where(@chart.filters)
          .where(filters.map(&:sql).join(" AND "))
          .group(@chart.group_by || "repository_id", "toDate(date_trunc('#{@frequency}', date))") # toDate to avoid hours when frequency is day
          .order("todate_date_trunc_#{@frequency}_date")
          .sum(:code)
      end

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
    @filters = current_account.filters.pluck(:name, :id)
  end

  def update
    chart_params = params.require(:chart).permit(
      :name,
      :group_by,
      :filters,
      :start_date,
      filter_ids: [],
      repository_names: [],
    )

    # When using the multiselect somehow params always come with an empty String as first element
    chart_params[:filter_ids].reject!(&:blank?)
    chart_params[:repository_names].reject!(&:blank?)

    @chart = current_account.charts.find(params[:id])

    if @chart.update(chart_params)
      redirect_to edit_chart_path(@chart), notice: "Updated #{@chart.name}!"
    else
      @repository_names = current_account.repositories.pluck(:name)

      render :edit
    end
  end
end
