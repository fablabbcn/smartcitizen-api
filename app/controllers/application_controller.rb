require 'error_handlers'
require 'pretty_json'

class ApplicationController < ActionController::API

  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Token::ControllerMethods
  # include AbstractController::Helpers::ClassMethods
  include ActionController::Helpers
  include ActionController::ImplicitRender

  # skip_before_action :verify_authenticity_token
  # protect_from_forgery with: :null_session

  respond_to :json

  include Pundit
  include PrettyJSON
  include ErrorHandlers

  after_action :verify_authorized, except: :index

  force_ssl if: :ssl_configured?

  before_filter :prepend_view_paths

private

  def prepend_view_paths
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
      elsif ActionController::HttpAuthentication::Token::token_and_options(request) # http token
        authenticate_with_http_token do |token, options|
          if token = ApiToken.find_by(token: token) and token.owner
            @current_user = token.owner
          else
            self.headers["WWW-Authenticate"] = %(Basic realm="Application", Token realm="Application")
            raise Smartcitizen::Unauthorized.new "Invalid API Token"
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

  # def doorkeeper_unauthorized_render_options
  #   raise Smartcitizen::Unauthorized.new("Invalid OAuth Token")
  # end

  def ssl_configured?
    request.host == 'new-api.smartcitizen.me'
  end

  # def render_cached_json(cache_key, opts = {}, &block)
  #   if true#Rails.env.production?
  #     opts[:expires_in] ||= 1.day
  #     expires_in opts[:expires_in], public: true
  #     return Rails.cache.fetch('e2', {raw: true}.merge(opts)) do
  #       render json: block.call, each_serializer: opts[:serializer]
  #     end
  #     # render json: JSON.parse(data)
  #   else
  #     return render json: block.call, each_serializer: opts[:serializer]
  #   end
  # end

end
