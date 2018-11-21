class HeaderCheck

  def initialize(app)
    @app = app
  end

  def call(env)
    if env['REQUEST_PATH'].try('match',/\A\/v\d/) and env['HTTP_ACCEPT'].try('include?', 'application/vnd.smartcitizen')
      env.delete('HTTP_ACCEPT')
    end
    status, headers, response = @app.call(env)
    [status, headers, response]
  end

end
