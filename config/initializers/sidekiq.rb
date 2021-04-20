Sidekiq.configure_server do |config|
  if concurrency = ENV["SIDEKIQ_CONCURRENCY"].presence
    config.options[:concurrency] = concurrency.to_i
  end
end
