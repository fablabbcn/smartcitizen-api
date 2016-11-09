if Rails.env.production?
  Figaro.require_keys('mqqt_host')
else
  ENV['mqqt_host'] = '127.0.0.1' if ENV['mqqt_host'].nil?
end
