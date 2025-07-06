module V0
  class MeshtasticController < ApplicationController
    before_action :verify_ingest_token
    after_action :verify_authorized, only: []

    def device_token
      @device = Device.includes(
        :owner, :tags, { sensors: :measurement }
      ).find_by(meshtastic_id: params[:meshtastic_id])
      render json: { token: @device.device_token } if @device
    end

    def sensor_id
      @sensor = Sensor.joins(
        :devices, :measurement
      ).where(
        measurement: { meshtastic_id: params[:measurement_meshtastic_id] },
        devices: { meshtastic_id: params[:device_meshtastic_id] }
      ).first
      @sensor ||= Measurement.find_by(meshtastic_id: params[:measurement_meshtastic_id])&.meshtastic_default_sensor
      render json: { id: @sensor.id } if @sensor
    end

    private

    def verify_ingest_token
      return if ingest_token && params[:ingest_token] == ingest_token

      render json: { error: "forbidden" }, status: 403
    end

    def ingest_token
      ENV["MESHTASTIC_INGEST_TOKEN"]
    end
  end
end
