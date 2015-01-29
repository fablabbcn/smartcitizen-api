module V0
  class StaticController < ApplicationController
    def home
      render json: { current_user_url: v0_me_index_url, devices_url: v0_devices_url, users_url: v0_users_url }
    end
  end
end
