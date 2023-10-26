module V0
  class ApplicationController < ActionController::API

    include ActionController::HttpAuthentication::Basic::ControllerMethods
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include ActionController::Helpers
    include ActionController::ImplicitRender

    include Pundit::Authorization
    include PrettyJSON
    include ErrorHandlers

    respond_to :json

    before_action :prepend_view_paths
    before_action :set_rate_limit_whitelist
    after_action :verify_authorized, except: :index

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

    def raise_ransack_errors_as_bad_request(&block)
      begin
        block.call
      rescue ArgumentError => e
        render json: { message: e.message, status: 400 }, status: 400
      end
    end

    def prepend_view_paths
      # is this still necessary?
      prepend_view_path "app/views/v0"
    end

    def set_rate_limit_whitelist
      if current_user(false)&.is_admin_or_researcher?
        Rack::Attack.cache.write("throttle_whitelist_#{request.remote_ip}", true, 5.minutes)
      end
    end

    def current_user(fail_unauthorized=true)
      if @current_user.nil?
        if doorkeeper_token
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
  end
end
