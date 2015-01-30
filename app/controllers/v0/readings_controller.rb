module V0
  class ReadingsController < ApplicationController

    def index
      @device = Device.find(params[:device_id])
      @readings = @device.readings
      render json: @readings
    end

    def create
      @device = Device.find_by_mac_address(params[:mac_address])
      @reading = Reading.create(device_id: @device.id, values: reading_params)
      if @reading.save
        render json: @reading, status: :created
      else
        render json: { errors: @reading.errors.full_messages }, status: :unprocessable_entity
      end
    end

private

    def reading_params
      params.permit(
        :values
      )
    end

  end
end
