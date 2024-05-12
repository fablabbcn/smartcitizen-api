module V0
  class ForwardingController < ApplicationController
    after_action :verify_authorized, except: :authorize
    def authorize
      topic = params[:topic]
      username = params[:username]
      token = topic && get_forwarding_token(topic)
      authorized = token && username && User.forwarding_subscription_authorized?(token, username)
      render json: { result: authorized ? "allow" : "ignore" }
    end

    private

    def get_forwarding_token(topic)
      match = topic.match(/forward\/([^\/]+)\//)
      match && match[1]
    end
  end
end

