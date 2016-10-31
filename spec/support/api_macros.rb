module ApiMacros

  def api_get action, params={}, version="0", headers={}
    get "/v#{version}/#{action}", params, headers
    JSON.parse(response.body) rescue {}
  end

  def api_post action, params={}, version="0", headers={}
    post "/v#{version}/#{action}", params, headers
    JSON.parse(response.body) rescue {}
  end

  def api_delete action, params={}, version="0", headers={}
    delete "/v#{version}/#{action}", params, headers
    JSON.parse(response.body) rescue {}
  end

  def api_put action, params={}, version="0", headers={}
    patch "/v#{version}/#{action}", params, headers
    JSON.parse(response.body) rescue {}
  end

end
