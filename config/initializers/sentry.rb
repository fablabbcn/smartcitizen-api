Sentry.init do |config|
  config.dsn = ENV['RAVEN_DSN_URL']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
end
