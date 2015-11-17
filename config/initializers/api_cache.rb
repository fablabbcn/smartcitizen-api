APICache.store = Moneta.new(:Redis,{
  cache: 10.minutes, # After this time fetch new data
  valid: 1.day,  # Maximum time to use old data :forever is a valid option
  period: 1.minute, # Maximum frequency to call API
  timeout: 5.seconds # API response timeout
  # :fail =>          # Value returned instead of exception on failure
})
