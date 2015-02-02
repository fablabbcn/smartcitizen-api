module V0
  class DevicesController < ApplicationController

    before_action :authorize!, only: [:create, :update]

    def world_map
      @devices = Device.all
      render text: @devices.to_json.to_msgpack
    end

    def index
      if params[:latlng]
        @devices = Device.includes(:sensors, :owner).near(params[:latlng], (params[:distance] || 1000))
      else
        @devices = Device.includes(:sensors, :owner).all
      end
      paginate json: @devices
    end

    def show
      @device = Device.find(params[:id])
      render json: @device
    end

    def update
      @device = current_user.devices.find(params[:id])
      if @device.update_attributes(device_params)
        render json: @device, status: :ok
      else
        render json: { errors: @device.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def create
      @device = current_user.devices.build(device_params)
      if @device.save
        render json: @device, status: :created
      else
        render json: { errors: @device.errors.full_messages }, status: :unprocessable_entity
      end
    end

private

    def device_params
      params.permit(
        :name,
        :description,
        :mac_address,
        :latitude,
        :longitude
      )
    end

  end
end
