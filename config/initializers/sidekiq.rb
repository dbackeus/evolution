require "sidekiq/worker_killer"

Sidekiq.configure_server do |config|
  if concurrency = ENV["SIDEKIQ_CONCURRENCY"].presence
    config.options[:concurrency] = concurrency.to_i
  end

  config.server_middleware do |chain|
    chain.add Sidekiq::WorkerKiller, grace_time: 5, max_rss: ENV["SIDEKIQ_MAX_RSS"].to_i # 0 = disabled
  end
end
