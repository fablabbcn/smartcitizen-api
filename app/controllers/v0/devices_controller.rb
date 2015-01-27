module V0
  class DevicesController < ApplicationController

    skip_before_action :doorkeeper_authorize!, only: [:index, :show]

    def index
      @devices = Device.all
      render json: @devices
    end

    def show
      @device = Device.find(params[:id])
      render json: @device
    end

    def update
      @device = current_user.devices.find(params[:id])
      if @device.update_attributes(device_params)
        head :no_content, status: :ok
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
      params.require(:device).permit(
        :name,
        :description,
        :mac_address,
        :latitude,
        :longitude
      )
    end

  end
end
