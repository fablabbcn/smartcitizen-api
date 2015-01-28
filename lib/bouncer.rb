class Bouncer

  def self.reject_with message
    { json: "{\"errors\":\"#{message}\"}", status: 401 }
  end

end
