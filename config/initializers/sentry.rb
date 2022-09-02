Sentry.init do |config|
    config.dsn = 'https://fcb3cf72f3854d42a24879198aa36f26@o82964.ingest.sentry.io/6712856'
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  
    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    config.traces_sample_rate = 1.0
end
  