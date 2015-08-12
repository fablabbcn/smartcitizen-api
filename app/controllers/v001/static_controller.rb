module V001
  class StaticController < ApplicationController

    def home
      render json: {
        devices: ':api_key/devices.json',
        lastpost: ':api_key/lastpost.json',
        posts: ':api_key/:device_id/posts.json?from_date=:from&to_date=:to&group_by=:range',
        me: ':api_key/me.json'
      }
    end

  end
end