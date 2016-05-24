module V0
  class ApplicationController < ActionController::API

    include ActionController::HttpAuthentication::Basic::ControllerMethods
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include ActionController::Helpers
    include ActionController::ImplicitRender

    include Pundit
    include PrettyJSON
    include ErrorHandlers

    respond_to :json

    before_action :prepend_view_paths
    after_action :verify_authorized, except: :index

    force_ssl if: :ssl_configured?

protected

    def check_missing_params *params_list
      missing_params = []
      params_list.each do |param|
        individual_params = param.split("||")
        missing_params << individual_params.join(" OR ") unless (params.keys & individual_params).any?
      end
      raise ActionController::ParameterMissing.new(missing_params.to_sentence) if missing_params.any?
    end

private

    def prepend_view_paths
      # is this still necessary?
      prepend_view_path "app/views/v0"
    end

    def current_user
      if @current_user.nil?
        if doorkeeper_token
          # return render text: 'abc'
          @current_user = User.find(doorkeeper_token.resource_owner_id)
        elsif ActionController::HttpAuthentication::Basic.has_basic_credentials?(request) # username and password
          authenticate_with_http_basic do |username, password|
            if user = User.find_by(username: username) and user.authenticate_with_legacy_support(password)
              @current_user = user
            else
              self.headers["WWW-Authenticate"] = %(Basic realm="Application", Token realm="Application")
              raise Smartcitizen::Unauthorized.new "Invalid Username/Password Combination"
            end
          end
        end
      end
      @current_user
    end
    helper_method :current_user

    def check_if_authorized!
      if current_user.nil?
        if params[:access_token]
          raise Smartcitizen::Unauthorized.new("Invalid OAuth2 Params")
        else
          raise Smartcitizen::Unauthorized.new("Authorization required")
        end
      end
    end

    def ssl_configured?
      false
      # request.host.match /api.smartcitizen.me/
    end

  end
end
