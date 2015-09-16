require 'net/http'
require 'uri'

module V0
  class ReadingsController < ApplicationController

    skip_after_action :verify_authorized

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

    def create
      # OLD IMPLEMENTATION
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
        Rails.logger.info "OLD ERROR"
        Rails.logger.info e
      end

      # NEW IMPLEMENTATION
      begin
        data = JSON.parse(request.headers['X-SmartCitizenData'])[0].merge({
          'mac' => request.headers['X-SmartCitizenMacADDR'],
          'version' => request.headers['X-SmartCitizenVersion'],
          'ip' => request.remote_ip
        })
        ENV['redis'] ? RawStorer.delay.new(data) : RawStorer.new(data)
      rescue Exception => e
        Rails.logger.info "NEW ERROR"
        Rails.logger.info e
      end

      render json: Time.current.utc.strftime("UTC:%Y,%-m,%-d,%H,%M,%S#") # render time for SCK to sync clock
    end

  end
end
