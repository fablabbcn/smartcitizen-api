module V001
  class DevicesController < ApplicationController

    def index
      @devices = Device.limit(10)
    end

    def show
      @devices = current_user.devices
    end

  end
end