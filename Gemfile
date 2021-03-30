source "https://rubygems.org"

ruby "2.7.2"

gem "bootsnap", require: false
gem "clickhouse-activerecord", git: "https://github.com/bdevel/clickhouse-activerecord", branch: "rails-6.1-support"
gem "pg"
gem "puma"
gem "rails"
gem "redis"
gem "simdjson"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem "listen"
  gem "rack-mini-profiler"
  gem "spring"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
