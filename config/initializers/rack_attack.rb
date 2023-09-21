class Rack::Attack
  class Request < ::Rack::Request
    def remote_ip
      @remote_ip ||= ActionDispatch::Request.new(env).remote_ip
    end
  end

  if Rails.env.development?
    # In environments/development.rb, config.cache_store = :null_store
    # Without a 'normal' cache it cannot count how many times a request has been made.
    # Instead we manually configure this cache for development mode:
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  limit_proc = ->(req) {
    user_is_whitelisted = Rack::Attack.cache.read("throttle_whitelist_#{req.remote_ip}")
    user_is_whitelisted ? Float::INFINITY : ENV.fetch("THROTTLE_LIMIT", 150).to_i
  }

  throttle('Throttle by IP', limit: limit_proc, period: 1.minute) do |request|
    request.remote_ip
  end

end
