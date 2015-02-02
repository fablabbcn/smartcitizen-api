
require 'bouncer'

class ApplicationController < ActionController::API

  include Pundit
  include ActionController::Serialization
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Token::ControllerMethods

  # http://stackoverflow.com/a/23018176
  ActionController::Renderers.add :json do |json, options|
    unless json.kind_of?(String)
      json = json.as_json(options) if json.respond_to?(:as_json)
      json = JSON.pretty_generate(json, options)
    end

    if options[:callback].present?
      self.content_type ||= Mime::JS
      "#{options[:callback]}(#{json})"
    else
      self.content_type ||= Mime::JSON
      json
    end
  end

  force_ssl if: :ssl_configured?

  rescue_from ActionController::ParameterMissing do |exception|
    render json: {message: exception.message}, status: :bad_request
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {message: exception.message}, status: :not_found
  end

  rescue_from Smartcitizen::NotAuthorized do |exception|
    render json: exception, status: :unauthorized
  end

private

  def authorize!
    raise Smartcitizen::NotAuthorized.new("Authorization required") if current_user.nil?
  end

  def current_user
    if @current_user.nil?
      if params[:access_token] and doorkeeper_token # oauth2
        unless @current_user = User.find(doorkeeper_token.resource_owner_id)
          raise Smartcitizen::NotAuthorized.new "Invalid OAuth2 Token"
        end
      elsif ActionController::HttpAuthentication::Basic.has_basic_credentials?(request) # username and password
        authenticate_with_http_basic do |username, password|
          if user = User.find_by(username: username) and user.authenticate_with_legacy_support(password)
            @current_user = user
          else
            self.headers["WWW-Authenticate"] = %(Basic realm="Application", Token realm="Application")
            raise Smartcitizen::NotAuthorized.new "Invalid Username/Password Combination"
          end
        end
      elsif ActionController::HttpAuthentication::Token::token_and_options(request) # http token
        authenticate_with_http_token do |token, options|
          if token = ApiToken.find_by(token: token) and token.owner
            @current_user = token.owner
          else
            self.headers["WWW-Authenticate"] = %(Basic realm="#{realm}", Token realm="#{realm}")
            raise Smartcitizen::NotAuthorized.new "Invalid API Token"
          end
        end
      end
    end
    @current_user
  end

  def doorkeeper_unauthorized_render_options
    Bouncer.reject_with("Invalid OAuth2 Token")
  end

  def ssl_configured?
    # Rails.env.production?
    false
  end

end
