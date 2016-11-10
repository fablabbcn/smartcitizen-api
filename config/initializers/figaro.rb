if Rails.env.production?
  Figaro.require_keys('mqtt_host')
else
  ENV['mqtt_host'] = '127.0.0.1' if ENV['mqtt_host'].nil?
end
