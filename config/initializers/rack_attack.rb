class Rack::Attack
  if Rails.env.development? || Rails.env.test?
    # In environments/development.rb, config.cache_store = :null_store
    # Without a 'normal' cache it cannot count how many times a request has been made.
    # Instead we manually configure this cache for development mode:
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  limit_proc = ->(req) {
    user = req.env["current_user"]
    user&.is_admin_or_researcher? ? Float::INFINITY : ENV.fetch("THROTTLE_LIMIT", 150)
  }

  throttle("Throttle by IP", limit: limit_proc, period: 1.minute) do |request|
    request.ip
  end
end
