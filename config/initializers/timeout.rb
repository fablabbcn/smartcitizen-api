#Rack::Timeout.timeout = 15 # seconds
Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 5
