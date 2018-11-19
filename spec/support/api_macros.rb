module ApiMacros

  def api_get action, p={}, version="0", h={}
    get "/v#{version}/#{action}", params:p, headers:h
    JSON.parse(response.body) rescue {}
  end

  def api_post action, p={}, version="0", h={}
    post "/v#{version}/#{action}", params:p, headers:h
    JSON.parse(response.body) rescue {}
  end

  def api_delete action, p={}, version="0", h={}
    delete "/v#{version}/#{action}", params:p, headers:h
    JSON.parse(response.body) rescue {}
  end

  def api_put action, p={}, version="0", h={}
    patch "/v#{version}/#{action}", params:p, headers:h
    JSON.parse(response.body) rescue {}
  end

end
