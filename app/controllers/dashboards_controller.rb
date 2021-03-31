class DashboardsController < ApplicationController
  PATTERNS = {
    specs: %r{\A./spec},
    implementation: %r{\A./(lib|app)},
    config: %r{\A./config},
  }.freeze

  def index
    @latest_imports = CodeFile
      .group(:repo)
      .maximum(:date)

    last_import_predicate = @latest_imports.map do |repo, date|
      "repo = '#{repo}' AND date = '#{date}'"
    end.join(" OR ")

    @repos_current_loc = CodeFile
      .where(last_import_predicate)
      .group(:repo)
      .order(sum_code: :desc)
      .sum(:code)

    monthly_imports = CodeFile.connection.query("SELECT repo, max(date) FROM code_files GROUP BY repo, date_trunc('month', date)").group_by(&:first)
    monthly_predicate = monthly_imports.map do |repo, repo_and_dates|
      dates = repo_and_dates.map { |repo, date| ApplicationRecord.connection.raw_connection.escape_literal date }.join(",")
      "repo = '#{repo}' AND date IN (#{dates})"
    end.join(" OR ")

    @repos_interval_total = CodeFile
      .where(monthly_predicate)
      .group(:repo, "date_trunc('month', date)")
      .order(:date_trunc_month_date)
      .sum(:code)

    @repos_interval_implementation = CodeFile
      .where(monthly_predicate)
      .where("match(path, '^\./(app|lib|client|src)/')")
      .where.not("match(path, '\.spec\..{2,3}$')")
      .where.not("match(path, '^\./src/(__mocks__|vendor|testUtils|generated)')")
      .group(:repo, "date_trunc('month', date)")
      .order(:date_trunc_month_date)
      .sum(:code)
  end
end