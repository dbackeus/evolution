module ApplicationHelper
  def buildless_module(name)
    url = BuildlessCache.modules[name]

    raise "module '#{name}' not found" unless url

    %(<script type="module-shim" src="#{url}"></script>).html_safe
  end

  COLORS = %w[
    #003f5c
    #2f4b7c
    #665191
    #a05195
    #d45087
    #f95d6a
    #ff7c43
    #ffa600
  ].freeze

  def highchart_series(repo_and_date_with_sum, frequency)
    start_date = repo_and_date_with_sum.keys.first.second
    end_date = repo_and_date_with_sum.keys.last.second

    # { "mynewsdesk" => { "2006-02-01" => 8056 , "2006-03-01" => 37809, ... }, "mnd-publish-frontend" => { "2017-05-01" => 21153, ... }, ... }
    repos_dates_locs = {}
    repo_and_date_with_sum.each do |(label, date), loc|
      label = current_account.repositories.find(label).name if label.is_a?(Integer) # TODO: Remove the N+1
      repos_dates_locs.deep_merge! label => { date => loc }
    end

    # ["2006-02-01", "2006-03-01", ...]
    range = range(start_date, end_date, frequency)

    # Fill blanks for dates where the repo is missing data
    repos_dates_locs.each do |repo, dates_with_loc|
      last_loc = 0
      range.each do |date|
        if loc = dates_with_loc[date]
          last_loc = loc
        else
          dates_with_loc[date] = last_loc
        end
      end
    end

    repos_dates_locs.map do |name, date_and_value|
      {
        type: "line",
        name: name,
        data: date_and_value.map { |date, value| [Time.parse(date).to_i * 1000, value] }.sort_by(&:first),
      }
    end.to_json
  end

  # { [repo_id, "2006-02-01"] => 8056, [repo_id, "2006-03-01"] => 37809, ... }
  def chart_data(repo_and_date_with_sum, frequency)
    start_date = repo_and_date_with_sum.keys.first.second
    end_date = repo_and_date_with_sum.keys.last.second

    # { "mynewsdesk" => { "2006-02-01" => 8056 , "2006-03-01" => 37809, ... }, "mnd-publish-frontend" => { "2017-05-01" => 21153, ... }, ... }
    repos_dates_locs = {}
    repo_and_date_with_sum.each do |(label, date), loc|
      label = current_account.repositories.find(label).name if label.is_a?(Integer) # TODO: Remove the N+1
      repos_dates_locs.deep_merge! label => { date => loc }
    end

    # ["2006-02-01", "2006-03-01", ...]
    range = range(start_date, end_date, frequency)

    # Fill blanks for dates where the repo is missing data
    repos_dates_locs.each do |repo, dates_with_loc|
      last_loc = 0
      range.each do |date|
        if loc = dates_with_loc[date]
          last_loc = loc
        else
          dates_with_loc[date] = last_loc
        end
      end
    end

    # {
    #   labels: ["2006-02-01", "2006-03-01", ...],
    #   datsets: [
    #     { label: "mynewsdesk", data: [8056, 37809, ...] },
    #     { label: "mnd-publish-frontend", data: [0, 0, ...] },
    #     ...
    #   ]
    # }
    {
      labels: range,
      datasets: to_datasets(repos_dates_locs),
    }.to_json
  end

  def import_progress(repository)
    range = repository.initial_commit_at.to_date..Date.today
    last_snapshot_on = repository.repository_snapshots.minimum(:date)
    current_index = range.entries.index(last_snapshot_on)
    dates_completed = range.count - current_index
    dates_completed / range.count.to_f
  end

  private

  def range(start_date, end_date, frequency)
    start_date = Date.parse(start_date)
    end_date = Date.parse(end_date)
    current_date = start_date

    range = []

    until current_date == end_date
      range << current_date.to_s
      current_date = current_date.send("next_#{frequency}") # ie. Date#(next_day|next_week|next_month)
      current_date = end_date if current_date > end_date
    end

    range
  end

  def to_datasets(repos_dates_locs)
    datasets = []
    repos_dates_locs.each_with_index do |(repo, dates_with_loc), index|
      color = COLORS[index % COLORS.length]
      datasets << {
        label: repo,
        data: dates_with_loc.sort.map(&:second),
        borderColor: color,
        backgroundColor: 'transparent',
      }
    end
    datasets
  end

  def url_for_github_app(app_name: ENV.fetch("GITHUB_APP_NAME"), callback_url:)
    query = Rack::Utils.build_query(state: Base64.encode64(callback_url))
    "https://github.com/apps/#{app_name}/installations/new?#{query}"
  end
end
