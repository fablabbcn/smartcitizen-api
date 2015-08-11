module V001
  class ReadingsController < ApplicationController

    def index
      # ?from_date=:from&to_date=:to&group_by=:range
      @readings = Reading.all
    end

    def show
      render json: Device.find(params[:device_id])
    end

  end
end
