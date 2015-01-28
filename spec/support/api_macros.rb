module ApiMacros

  def api_get action, params={}, version="0"
    get "/v#{version}/#{action}", params
    JSON.parse(response.body) rescue {}
  end

  def api_post action, params={}, version="0"
    post "/v#{version}/#{action}", params
    JSON.parse(response.body) rescue {}
  end

  def api_delete action, params={}, version="0"
    delete "/v#{version}/#{action}", params
    JSON.parse(response.body) rescue {}
  end

  def api_put action, params={}, version="0"
    patch "/v#{version}/#{action}", params
    JSON.parse(response.body) rescue {}
  end

end
