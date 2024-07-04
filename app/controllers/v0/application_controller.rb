require_relative '../../helpers/user_helper'
module V0
  class ApplicationController < ActionController::API

    include ActionController::HttpAuthentication::Basic::ControllerMethods
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include ActionController::Helpers
    include ActionController::ImplicitRender
    include ActionController::Caching

    include PrettyJSON
    include ErrorHandlers

    helper ::UserHelper
    include ::UserHelper

    include SharedControllerMethods

    helper ::PresentationHelper
    include ::PresentationHelper

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

    def check_date_param_format(param_name)
      return true if !params[param_name]
      return true if params[param_name] =~ /^\d+$/
      begin
        Time.parse(params[param_name])
        return true
      rescue
        message = "The #{param_name} parameter must be an ISO8601 format date or datetime or an integer number of seconds since the start of the UNIX epoch."
        render json: { message:  message, status: 400 }, status: 400
        return false
      end
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
