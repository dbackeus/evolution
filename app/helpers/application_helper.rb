module ApplicationHelper
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

  # { ["mynewsdesk", "2006-02-01"] => 8056, ["mynewsdesk", "2006-03-01"] => 37809, ... }
  def chart_data(repo_and_date_with_sum)
    start_date = repo_and_date_with_sum.keys.first.second
    end_date = repo_and_date_with_sum.keys.last.second

    # { "mynewsdesk" => { "2006-02-01" => 8056 , "2006-03-01" => 37809, ... }, "mnd-publish-frontend" => { "2017-05-01" => 21153, ... }, ... }
    repos_dates_locs = {}
    repo_and_date_with_sum.each do |(repo, date), loc|
      repos_dates_locs.deep_merge! repo => { date => loc }
    end

    # ["2006-02-01", "2006-03-01", ...]
    range_of_months = monthly_range(start_date, end_date)

    # Fill blanks for dates where the repo is missing data
    repos_dates_locs.each do |repo, dates_with_loc|
      last_loc = 0
      range_of_months.each do |date|
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
      labels: range_of_months,
      datasets: to_datasets(repos_dates_locs),
    }.to_json
  end

  private

  def monthly_range(start_date, end_date)
    start_date = Date.parse(start_date)
    end_date = Date.parse(end_date)
    current_month = start_date

    range = []

    while current_month <= end_date
      range << current_month.to_s
      current_month = current_month.next_month
    end

    range
  end

  def to_datasets(repos_dates_locs)
    datasets = []
    repos_dates_locs.each_with_index do |(repo, dates_with_loc), index|
      color = COLORS[index]
      datasets << {
        label: repo,
        data: dates_with_loc.sort.map(&:second),
        borderColor: color,
        backgroundColor: 'transparent',
      }
    end
    datasets
  end
end
