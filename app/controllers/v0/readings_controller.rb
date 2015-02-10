module V0
  class ReadingsController < ApplicationController

    # def index
    #   @readings = Reading.all
    #   render json: @readings
    # end

    def create
      @device = Device.find_by!(mac_address: params[:mac_address])
      @reading = Reading.create(device_id: @device.id, values: params[:values])
      if @reading.save
        render json: @reading, status: :created
      else
        render json: { errors: @reading.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def add
      if @device = Device.find_by(mac_address: params[:mac_address])
        @reading = @device.add_reading(recorded_at: params[:recorded_at], values: params[:values])
      end
      render json: Time.now.utc.strftime("UTC:%Y,%-m,%-d,%H,%M,%S#")
    end

private

    def reading_params
      params.permit(
        :mac_address,
        :recorded_at,
        values: []
      )
    end

  end
end
