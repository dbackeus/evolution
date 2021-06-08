if Rails.env.development?
  Listen.to("public/buildless", only: /\.js$/) do |modified, added, removed|
    all_changes = modified + added + removed
    Rails.logger.info("[#{Process.pid}] Busting the buildless cache due to changed files: #{all_changes}")
    BuildlessCache.purge
  end.start
end
