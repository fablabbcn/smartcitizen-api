module SharedControllerMethods

  include Pundit::Authorization

  def self.included(klass)
    klass.helper_method :current_user
  end

  def current_user(fail_unauthorized=true)
    if @current_user.nil?
      if session[:user_id]
        @current_user = User.find(session[:user_id])
      elsif doorkeeper_token
        # return render text: 'abc'
        @current_user = User.find(doorkeeper_token.resource_owner_id)
      elsif ActionController::HttpAuthentication::Basic.has_basic_credentials?(request) # username and password
        authenticate_with_http_basic do |username, password|
          if user = User.find_by(username: username) and user.authenticate_with_legacy_support(password)
            @current_user = user
          elsif fail_unauthorized
            self.headers["WWW-Authenticate"] = %(Basic realm="Application", Token realm="Application")
            raise Smartcitizen::Unauthorized.new "Invalid Username/Password Combination"
          end
        end
      end
    end
    @current_user
  end
end
