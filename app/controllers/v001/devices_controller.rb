module V001
  class DevicesController < ApplicationController

    def index
      @devices = Device.limit(10)
    end

  end
end