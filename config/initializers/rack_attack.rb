Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new # defaults to Rails.cache

class Rack::Attack

  throttle('Throttle by IP', limit: 100, period: 1.minute) do |request|
    request.ip
  end

end
