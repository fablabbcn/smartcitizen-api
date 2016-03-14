# $analytics = Minuteman.new
Minuteman.configure do |config|
  # You need to use Redic to define a new Redis connection
  config.redis = Redic.new("redis://127.0.0.1:6379/1")

  # The prefix affects operations
  config.prefix = "Tomato"

  # The patterns is what Minuteman uses for the tracking/counting and the
  # different analyzers
  config.patterns = config.patterns.merge({
    week: -> (time) { time.strftime("%Y-%W") }
  })
end
