Sentry.init do |config|
  config.dsn = ENV['RAVEN_DSN_URL']
  config.breadcrumbs_logger = [:sentry_logger, :active_support_logger, :http_logger]
  config.excluded_exceptions = ["RetryMQTTMessageJob::RetryMessageHandlerError"]
end
