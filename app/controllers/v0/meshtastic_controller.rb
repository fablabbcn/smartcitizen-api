module V0
  class MeshtasticController < ApplicationController
    before_action :verify_ingest_token
    after_action :verify_authorized, only: []

    def device_token
      @device = Device.includes(
        :owner, :tags, { sensors: :measurement }
      ).find_by(meshtastic_id: params[:meshtastic_id])
      render json: { token: @device.device_token }
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
