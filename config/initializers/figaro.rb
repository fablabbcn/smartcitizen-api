if Rails.env.development? || Rails.env.test?
  Figaro.env.mqqt_host_key == '127.0.0.1' unless Figaro.env.mqqt_host_key?
else
  Figaro.require_keys('mqqt_host')
end
