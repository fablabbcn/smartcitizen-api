module V0
  class ReadingsController < ApplicationController

    skip_after_action :verify_authorized

    def index
      @device = Device.find(params[:device_id])
      @readings = @device.all_readings
      # "granularity= year / month / week / day / hour
      render json: @readings
    end

    def add
      # if @device = Device.find_by(mac_address: params[:mac_address])
      #   @reading = @device.add_reading(recorded_at: params[:recorded_at], values: params[:values])
      # end
      begin
        mac = request.headers['X-SmartCitizenMacADDR']
        version = request.headers['X-SmartCitizenVersion']
        data = request.headers['X-SmartCitizenData']
        @reading = Reading.create_from_api(mac, version, data, request.remote_ip)
        authorize @reading, :create?
      rescue Exception => e
        Rails.logger.info e
      end
      render json: Time.current.utc.strftime("UTC:%Y,%-m,%-d,%H,%M,%S#")
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
