module V001
  class DevicesController < ApplicationController

    def show
      @device = Device.find(params[:device_id])
      render json: { device: @device }
    end

    def index
      sql = "SELECT devices.id, devices.title, users.username, devices.description, devices.location, devices.city, devices.country, devices.exposure, devices.elevation, devices.geo_lat, devices.geo_long, devices.created, devices.last_insert_datetime FROM devices LEFT OUTER JOIN users ON devices.user_id = users.id"
      records = MySQL.connection.execute(sql)
      keys = %w(id title username description location city country exposure elevation geo_lat geo_long created last_insert_datetime)
      render json: Oj.dump({
        devices: records.map{ |record| Hash[keys.zip(record)] }
      }, mode: :compat)
    end

    def current_user_index
      # @devices = []
      # current_user.devices.each do |device|
      #   @devices << {
      #     device: device
      #   }
      # end
      # devices for a user
      @devices = current_user.devices.order(:id)
    end

  end
end