module V0
  class ReadingsController < ApplicationController

    def index
      @device = Device.find(params[:device_id])
      @readings = @device.readings
      render json: @readings
    end

  end
end
