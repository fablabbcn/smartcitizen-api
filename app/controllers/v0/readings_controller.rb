require 'net/http'
require 'uri'

module V0
  class ReadingsController < ApplicationController

    skip_after_action :verify_authorized

    def index
      check_missing_params("rollup", "sensor_key||sensor_id") # sensor_key or sensor_id
      render json: NewKairos.query(params)
    end

    def create
      begin
        data = JSON.parse(request.headers['X-SmartCitizenData'])[0].merge({
          'mac' => request.headers['X-SmartCitizenMacADDR'],
          'version' => request.headers['X-SmartCitizenVersion'],
          'ip' => request.remote_ip
        })
        ENV['redis'] ? RawStorer.delay.new(data) : RawStorer.new(data)
      rescue Exception => e
        Airbrake.notify_airbrake(e, parameters: params, cgi_data: ENV.to_hash)
        Rails.logger.info "NEW ERROR"
        Rails.logger.info e
      end
      render json: Time.current.utc.strftime("UTC:%Y,%-m,%-d,%H,%M,%S#") # render time for SCK to sync clock
    end

  end
end
