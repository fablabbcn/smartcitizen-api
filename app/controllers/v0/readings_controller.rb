require 'net/http'
require 'uri'

module V0
  class ReadingsController < ApplicationController

    skip_after_action :verify_authorized, except: :create
    skip_after_action :verify_authorized

    def index
      check_missing_params("rollup", "sensor_key||sensor_id") # sensor_key or sensor_id
      return unless check_date_param_format("from")
      return unless check_date_param_format("to")
      data = Kairos.query(params)
      if params["localtimes"] == "1"
        render json: convert_to_local_times(data)
      else
        render json: data
      end
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
      if params[:data].first['recorded_at'].blank?
        render json: { id: "bad", message: "Timestamp cannot be empty!", url: "", errors: "" }, status: :ok
      else
        SendToDatastoreJob.perform_later(params[:data].to_json, params[:id])
        render json: { id: "ok", message: "Data successfully sent to queue", url: "", errors: "" }, status: :ok
      end
    end

    def legacy_create
      if request.headers['X-SmartCitizenData']
        storer = RawStorer.new
        JSON.parse(request.headers['X-SmartCitizenData']).each do |raw_reading|
          mac = request.headers['X-SmartCitizenMacADDR']
          version = request.headers['X-SmartCitizenVersion']
          ip = request.headers['X-SmartCitizenIP'] || request.remote_ip
          storer.store(raw_reading,mac,version,ip)
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

      if @device.request_csv_archive_for!(current_user)
        render json: { id: "ok", message: "CSV Archive job added to queue", url: "", errors: "" }, status: :ok
      else
        render json: { id: "enhance_your_calm", message: "You can only make this request once every 6 hours, (this is rate-limited)", url: "", errors: "" }, status: 420
      end
    end


    private

    def convert_to_local_times(data)
      tz = current_user&.time_zone || ActiveSupport::TimeZone["Etc/UTC"]
      from = tz.at(data["from"])
      to = tz.at(data["to"])
      readings = data["readings"].map {|reading|
        [tz.at(reading[0]), reading[1]]
      }
      data.merge({ from: from, to: to, readings: readings })
    end

  end
end
