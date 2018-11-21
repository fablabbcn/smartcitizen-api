class DeleteResponseHeaders

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    # headers = headers.slice('Link', 'Per-Page', 'Total') unless env['QUERY_STRING'].include? "allheaders"
    headers = {} if env['QUERY_STRING'] == "noheaders"
    [status, headers, response]
  end

end
