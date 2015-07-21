module V001
  class DevicesController < ApplicationController

    def index
      # all devices
      @devices = Device.limit(params[:limit])
    end

    def current_user_index
      # devices for a user
      @devices = current_user.devices
    end

  end
end