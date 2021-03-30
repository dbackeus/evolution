class DashboardsController < ApplicationController
  PATTERNS = {
    specs: %r{\A./spec},
    implementation: %r{\A./(lib|app)},
    config: %r{\A./config},
  }.freeze

  def index
    @latest_imports = CodeFile.select("repo, max(date) as date").group(:repo)

    last_import_predicate = @latest_imports.map do |import|
      "repo = '#{import.repo}' AND date = '#{import.date}'"
    end.join(" OR ")

    @repos_loc = CodeFile.select("repo, sum(code) as loc").where(last_import_predicate).order(loc: :desc).group(:repo)
  end

  private


  def json_to_structured(tokei_json)
    response = {
      total: {},
    }

    tokei_json.each do |language, content|
      reports = content.fetch("reports")

      response[:total][language.to_sym] = {
        files: reports.length,
        blanks: content.fetch("blanks"),
        comments: content.fetch("comments"),
        code: content.fetch("code"),
      }

      content.fetch("reports").each do |report|
        name = report.fetch("name")
        stats = report.fetch("stats")
        PATTERNS.each do |category, pattern|
          if name.match?(pattern)
            response[category] ||= {}
            response[category][language] ||= {
              files: 0,
              blanks: 0,
              comments: 0,
              code: 0,
            }
            response[category][language][:files] += 1
            response[category][language][:blanks] += stats.fetch("blanks")
            response[category][language][:code] += stats.fetch("code")
            response[category][language][:comments] += stats.fetch("comments")
          end
        end
      end
    end

    response
  end
end