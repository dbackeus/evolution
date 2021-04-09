class DashboardsController < ApplicationController
  before_action :authenticate_user!

  PATTERNS = {
    specs: %r{\A./spec},
    implementation: %r{\A./(lib|app)},
    config: %r{\A./config},
  }.freeze

  def index
    if range = params[:range]
      from, to = range.split("..").map(&Date.method(:parse))
      @range = from..to
      scope = current_account.code_files.where(date: @range)
      range_distance_in_days = (to - from).to_i
      @frequency =
        case range_distance_in_days
          when ..31 then "day"
          when ..300 then "week"
          else "month"
        end
    else
      @frequency = "month"
      scope = current_account.code_files
    end

    @latest_imports = CodeFile
      .group(:repository_id)
      .maximum(:date)

    last_import_predicate = @latest_imports.map do |repository_id, date|
      "repository_id = '#{repository_id}' AND date = '#{date}'"
    end.join(" OR ")

    @repos_current_loc = CodeFile
      .where(last_import_predicate)
      .group(:repository_id)
      .order(sum_code: :desc)
      .sum(:code)

    # { ["mynewsdesk", "2016-06-01"] => Thu, 30 Jun 2016, ["mynewsdesk", "2007-03-01"] => Wed, 28 Mar 2007, ... }
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

    @repos_interval_total = CodeFile
      .where(interval_predicate)
      .group(:repository_id, "toDate(date_trunc('#{@frequency}', date))") # toDate to avoid hours when frequency is day
      .order("todate_date_trunc_#{@frequency}_date")
      .sum(:code)

    @repos_interval_implementation = CodeFile
      .where(interval_predicate)
      .where("match(path, '^\./(app|lib|client|src)/')")
      .where.not("match(path, '\.spec\..{2,3}$')")
      .where.not("match(path, '^\./src/(__mocks__|vendor|testUtils|generated)')")
      .group(:repository_id, "toDate(date_trunc('#{@frequency}', date))") # toDate to avoid hours when frequency is day
      .order("todate_date_trunc_#{@frequency}_date")
      .sum(:code)
  end
end
