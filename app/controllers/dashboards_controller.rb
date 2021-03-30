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

    @repos_loc = CodeFile
      .where(last_import_predicate)
      .group(:repo)
      .order(sum_code: :desc)
      .sum(:code)
  end
end