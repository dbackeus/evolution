source "https://rubygems.org"

ruby File.read(".ruby-version").chomp

gem "bootsnap", require: false
gem "clickhouse-activerecord", git: "https://github.com/bdevel/clickhouse-activerecord", branch: "rails-6.1-support"
gem "devise", git: "https://github.com/heartcombo/devise" # omniauth 2.0 support: https://github.com/heartcombo/devise/issues/5368
gem "dotenv-rails"
gem "jwt"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
gem "pg"
gem "puma"
gem "rails"
gem "redis"
gem "reline" # speed up multiline pasting in console (https://github.com/ruby/irb/issues/43)
gem "rollbar"
gem "rorvswild" # APM (https://www.rorvswild.com/)
gem "sidekiq"
gem "sidekiq-worker-killer"
gem "sidekiq-scheduler"
gem "simdjson"
gem "typhoeus"

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
