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

  end
end
