module V0
  class ReadingsController < ApplicationController

    def index
      @device = Device.find(params[:device_id])
      allmonths = (@device.created_at.year-1..Time.now.year).map{|y| ('01'..'12').map{|m| "#{y}#{m}" }}.flatten
      # from = allmonths.index((@device.created_at - 1.year).strftime("%Y%m"))
      to = allmonths.index(Time.now.strftime("%Y%m"))
      months = allmonths[0..to]
      @readings = @device.readings.where(recorded_month: months)
      render json: @readings
    end

    def create
      @device = Device.find_by!(mac_address: params[:mac_address])
      @reading = Reading.create(device_id: @device.id, values: params[:values])
      authorize @reading
      if @reading.save
        render json: @reading, status: :created
      else
        render json: { errors: @reading.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def add
      # if @device = Device.find_by(mac_address: params[:mac_address])
      #   @reading = @device.add_reading(recorded_at: params[:recorded_at], values: params[:values])
      # end

      begin
        mac = request.headers['X-SmartCitizenMacADDR']
        version = request.headers['X-SmartCitizenVersion']
        data = JSON.parse(request.headers['X-SmartCitizenData'])[0]
        @reading = Reading.create_from_api(mac, version, data, request.remote_ip)
        authorize @reading, :create?
      rescue Exception => e
        Rails.logger.info e
      end

      render json: Time.now.utc.strftime("UTC:%Y,%-m,%-d,%H,%M,%S#")
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
