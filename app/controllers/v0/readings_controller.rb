require 'net/http'
require 'uri'

module V0
  class ReadingsController < ApplicationController

    skip_after_action :verify_authorized, except: :create
    skip_after_action :verify_authorized

    def index
      check_missing_params("rollup", "sensor_key||sensor_id") # sensor_key or sensor_id
      render json: Kairos.query(params)
    end

    def create
      check_missing_params("data")
      @device = Device.includes(:components).find(params[:id])
      authorize @device

      # NOTE: if we do all the checks HERE, we can return correct error codes before sending to a job
      # Is the device valid?
      # Are the sensors valid?

      # Kairos will error if no Timestamp (recorded_at) is given.
      # It is better to error before the job, to let the user know what is wrong
      # TODO: Currently we fail all datapoints even if only the first out of a 100 is missing a Timestamp.
      # Do we need to change that?

      # In order to tell the user if there is an invalid Timestamp, we perform the checks here, not in a job.
      # We only check if the dataset is smaller then X datapoints
      if params[:data].size < 40000
        params[:data].each do |item|
          if item['recorded_at'].blank?
            render json: { id: "ok", message: "Timestamp cannot be empty!", url: "", errors: "" }, status: :ok
            return
          end
          timestamp = Time.parse(item['recorded_at'])
          if timestamp.blank?
            render json: { id: "ok", message: "Timestamp (#{timestamp}) invalid", url: "", errors: "" }, status: :ok
            return
          elsif timestamp > 1.day.from_now
            render json: { id: "ok", message: "Timestamp (#{timestamp}) cannot be in the future", url: "", errors: "" }, status: :ok
            return
          elsif timestamp < 3.years.ago
            render json: { id: "ok", message: "Timestamp (#{timestamp}) is older than 3 years old", url: "", errors: "" }, status: :ok
            return
          end
        end
      end

      SendToDatastoreJob.perform_later(params[:data].to_json, params[:id])
      render json: { id: "ok", message: "Data successfully sent to queue", url: "", errors: "" }, status: :ok

    end

    def legacy_create

      if request.headers['X-SmartCitizenData']
        JSON.parse(request.headers['X-SmartCitizenData']).each do |raw_reading|

          mac = request.headers['X-SmartCitizenMacADDR']
          version = request.headers['X-SmartCitizenVersion']
          ip = (request.headers['X-SmartCitizenIP'] || request.remote_ip)

          RawStorer.new(raw_reading,mac,version,ip)
        end
      end

      datetime
    end

    def datetime
      render json: Time.current.utc.strftime("UTC:%Y,%-m,%-d,%H,%M,%S#")
    end

    def csv_archive
      @device = Device.find(params[:id])
      authorize @device, :update?

      if @device.kit.nil?
        render json: { id: "error", message: "Device does not have a kit", url: "", errors: "" }, status: 420
        return
      end

      if !@device.csv_export_requested_at or (@device.csv_export_requested_at < 15.minutes.ago)
        @device.update_column(:csv_export_requested_at, Time.now.utc)
        if Rails.env.test?
          UserMailer.device_archive(@device.id, current_user.id).deliver_now
        else
          UserMailer.device_archive(@device.id, current_user.id).deliver_later
        end
        render json: { id: "ok", message: "CSV Archive job added to queue", url: "", errors: "" }, status: :ok
      else
        render json: { id: "enhance_your_calm", message: "You can only make this request once every 6 hours, (this is rate-limited)", url: "", errors: "" }, status: 420
      end
    end

  end
end
