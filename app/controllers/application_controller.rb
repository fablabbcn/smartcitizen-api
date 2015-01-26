class ApplicationController < ActionController::API

  include ActionController::Serialization

  before_action :doorkeeper_authorize!

private

  def current_user
    if doorkeeper_token
      @current_user ||= User.find(doorkeeper_token.resource_owner_id)
    end
  end

  def doorkeeper_unauthorized_render_options
    { json: '{"errors":"The access token is invalid"}' }
  end

end
