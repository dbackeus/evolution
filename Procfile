web: bundle exec rackup -s puma -p $PORT -E $RACK_ENV
worker: bundle exec sidekiq
release: bundle exec rails db:migrate
