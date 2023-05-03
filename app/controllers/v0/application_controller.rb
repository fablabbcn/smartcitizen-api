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
      @current_user ||= request.env["current_user"]
      if @current_user.nil?
        self.headers["WWW-Authenticate"] = %(Basic realm="Application", Token realm="Application")
        raise Smartcitizen::Unauthorized.new "Invalid Username/Password Combination"
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
