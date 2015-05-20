module V0
  class DevicesController < ApplicationController

    before_action :check_if_authorized!, only: [:create, :update]
    after_action :verify_authorized, except: [:index, :world_map]

    # caches_action :world_map, expires_in: 2.minutes

    def world_map
      @devices = Device.includes(:owner).map do |device|
        {
          id: device.id,
          name: device.name,
          description: (device.description.present? ? device.description : nil),
          owner_id: device.owner_id,
          owner_username: device.owner_username,
          latitude: device.latitude,
          longitude: device.longitude,
          city: device.city,
          country_code: device.country_code,
          kit_id: device.kit_id,
          status: device.status,
          exposure: device.exposure,
          data: device.data,
          added_at: device.added_at
        }
      end
      render json: @devices
      # render json: ActiveModel::ArraySerializer.new(
      #   Device.includes(:owner,:kit),
      #   each_serializer: WorldMapDevicesSerializer
      # )
      # # json = Rails.cache.fetch("devices/world_map/1", expires_in: 5.seconds) do end
      # # render_cached_json("devices:world_map", expires_in: 6.minutes, serializer: WorldMapDevicesSerializer) do
      # #   @devices = Device.all#select(:id,:name,:description,:latitude,:longitude)
      # # end
    end

    def index

      @q = Device.includes(:owner).ransack(params[:q])
      @devices = @q.result(distinct: true)

      if params[:near]
        if params[:near] =~ /\A(\-?\d+(\.\d+)?),\s*(\-?\d+(\.\d+)?)\z/
          @devices = @devices.near(params[:near].split(','), (params[:within] || 1000))
        else
          return render json: { id: "bad_request", message: "Malformed near parameter", url: 'https://fablabbcn.github.io/smartcitizen-api-docs/#get-all-devices', errors: nil }, status: :bad_request
        end
      end

      @devices = paginate(@devices)

      # json:
      #, each_serializer: DetailedDeviceSerializer
    end

    def show
      @device = Device.includes(:kit, :owner, :sensors).find(params[:id])
      authorize @device
      @device
    end

    def update
      @device = current_user.devices.find(params[:id])
      authorize @device
      if @device.update_attributes(device_params)
        render json: @device, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @device.errors
        # render json: { errors: @device.errors }, status: :unprocessable_entity
      end
    end

    def create
      @device = current_user.devices.build(device_params)
      authorize @device
      if @device.save
        render json: @device, status: :created
      else
        raise Smartcitizen::UnprocessableEntity.new @device.errors#.full_messages
        # render json: { errors: @device.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      @device = Device.find(params[:id])
      authorize @device
      if @device.destroy
        render json: @device, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @device.errors
        # render json: { errors: @device.errors }, status: :unprocessable_entity
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
