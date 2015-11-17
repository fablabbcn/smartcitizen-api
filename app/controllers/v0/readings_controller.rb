require 'net/http'
require 'uri'

module V0
  class ReadingsController < ApplicationController

    skip_after_action :verify_authorized

    def index
      check_missing_params("rollup", "sensor_key||sensor_id") # sensor_key or sensor_id
      render json: Kairos.query(params)
    end

    def create
      begin
        JSON.parse(request.headers['X-SmartCitizenData']).each do |raw_reading|
          begin
            data = raw_reading.merge({
              'mac' => request.headers['X-SmartCitizenMacADDR'],
              'version' => request.headers['X-SmartCitizenVersion'],
              'ip' => request.remote_ip
            })
            ENV['redis'] ? RawStorer.delay.new(data) : RawStorer.new(data)
          rescue Exception => e
            begin
              BadReading.add(data, request.headers['X-SmartCitizenIP'])
            rescue Exception => e
              notify_airbrake(e)
            end
            notify_airbrake(e)
          end
        end
      rescue Exception => e
        notify_airbrake(e)
      end
      render json: Time.current.utc.strftime("UTC:%Y,%-m,%-d,%H,%M,%S#") # render time for SCK to sync clock
    end

    def csv_archive
      @device = Device.find(params[:id])
      authorize @device, :update?
      if !@device.csv_export_requested_at or (@device.csv_export_requested_at < 6.hours.ago)
        @device.update_column(:csv_export_requested_at, Time.now.utc)
        ENV['redis'] ? UserMailer.delay.device_archive(@device.id, current_user.id) : UserMailer.device_archive(@device.id, current_user.id).deliver_now
        render json: { id: "ok", message: "CSV Archive job added to queue", url: nil, errors: nil }, status: :ok
      else
        render json: { id: "enhance_your_calm", message: "You can only make this request once every 6 hours, (this is rate-limited)", url: nil, errors: nil }, status: 420
      end
    end

  end
end
