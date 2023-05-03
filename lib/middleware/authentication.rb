module Middleware
  class Authentication
    class AuthenticatedRequest
      include Doorkeeper::Rails::Helpers
      include ActionController::HttpAuthentication::Basic::ControllerMethods

      def initialize(env)
        @env = env
      end

      def current_user
        if @current_user.nil?
          if doorkeeper_token
            @current_user = User.find(doorkeeper_token.resource_owner_id)
          elsif ActionController::HttpAuthentication::Basic.has_basic_credentials?(request) # username and password
            authenticate_with_http_basic do |username, password|
              if user = User.find_by(username: username) and user.authenticate_with_legacy_support(password)
                @current_user = user
              else
              end
            end
          else
          end
        end
        @current_user
      end

      private

      def request
        @request ||= ActionDispatch::Request.new(env)
      end

      attr_reader :env
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      request = AuthenticatedRequest.new(env)
      env["current_user"] = request.current_user
      app.call(env)
    end

    private

    attr_reader :app
  end
end
