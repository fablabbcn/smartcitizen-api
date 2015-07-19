require 'net/http'
require 'uri'

module V0
  class ReadingsController < ApplicationController

    skip_after_action :verify_authorized

    def add
      begin
        mac = request.headers['X-SmartCitizenMacADDR']
        version = request.headers['X-SmartCitizenVersion']
        data = JSON.parse(request.headers['X-SmartCitizenData'])[0].merge({
          'version' => version,
          'ip' => request.remote_ip
        })
        # @reading = Kairos.delay.create_from_api(mac, data)

        ENV['redis'] ? Calibrator.delay.new(mac, data) : Calibrator.new(mac, data)

      rescue Exception => e
        Rails.logger.info e
      end
      render json: Time.current.utc.strftime("UTC:%Y,%-m,%-d,%H,%M,%S#") # render time for SCK to sync clock
    end

    def index
      missing_params = []
      %w(rollup sensor_id).each do |param|
        missing_params << param unless params[param]
      end
      if missing_params.any?
        raise ActionController::ParameterMissing.new(missing_params.to_sentence)
      else
        render json: Kairos.query(params)
      end
    end

  end
end
