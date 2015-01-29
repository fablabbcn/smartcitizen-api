module V0
  class StaticController < ApplicationController
    def home
      render json: { devices_url: v0_devices_url, users_url: v0_users_url }
    end
  end
end
