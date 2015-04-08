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
      begin
        mac = request.headers['X-SmartCitizenMacADDR']
        version = request.headers['X-SmartCitizenVersion']
        data = request.headers['X-SmartCitizenData']

        Keen.publish("adds", { :mac => mac, :version => version, :data => data }) if Rails.env.production?

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
