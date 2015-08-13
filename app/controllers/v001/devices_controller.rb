module V001
  class DevicesController < ApplicationController

    def show
      @device = LegacyDevice.find(params[:device_id])
      render json: Oj.dump({ device: @device }, mode: :compat)
    end

    def index
      # raw SQL required for performance reasons
      sql = "SELECT devices.id, devices.title, users.username, devices.description, devices.location, devices.city, devices.country, devices.exposure, devices.elevation, devices.geo_lat, devices.geo_long, CONCAT(devices.created, ' UTC') , CONCAT(COALESCE(devices.last_insert_datetime, ''), ' UTC') FROM devices LEFT OUTER JOIN users ON devices.user_id = users.id"
      records = MySQL.connection.execute(sql)
      keys = %w(id title username description location city country exposure elevation geo_lat geo_long created last_insert_datetime)
      render json: Oj.dump({
        devices: records.map{ |record| Hash[keys.zip(record)] }
      }, mode: :compat)
    end

    def current_user_index
      @devices = LegacyDevice.where(user_id: current_user.id)
      render json: Oj.dump({ devices: @devices }, mode: :compat)
    end

  end
end