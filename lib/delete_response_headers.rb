class DeleteResponseHeaders

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    headers = {} unless env['QUERY_STRING'] == "allheaders"
    [status, headers, response]
  end

end
