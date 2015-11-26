module V001
  class StaticController < ApplicationController

    skip_before_action :check_api_key

    def home
      expires_in 5.minutes, public: true
      params[:pretty] = true
      render json: {
        api_documentation_url: 'http://legacy-api-docs.smartcitizen.me/',
        devices_url: 'http://api.smartcitizen.me/v0.0.1/:api_key/devices.json',
        lastpost_url: 'http://api.smartcitizen.me/v0.0.1/:api_key/lastpost.json',
        posts_url: 'http://api.smartcitizen.me/v0.0.1/:api_key/:device_id/posts.json?from_date=:from&to_date=:to&group_by=:range',
        me_url: 'http://api.smartcitizen.me/v0.0.1/:api_key/me.json'
      }
    end

  end
end