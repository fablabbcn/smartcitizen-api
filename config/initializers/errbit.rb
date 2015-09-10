Airbrake.configure do |config|
  config.api_key = ENV['errbit_api_key']
  config.host    = ENV['errbit_host']
  config.port    = ENV['errbit_port']
  config.secure  = config.port == ENV['errbit_port']
end
