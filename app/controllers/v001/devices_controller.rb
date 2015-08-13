module V001
  class DevicesController < ApplicationController

    def show
      @device = LegacyDevice.find(params[:device_id])
      render json: Oj.dump({ device: @device }, mode: :compat)
    end

    def index
      # raw SQL required for performance reasons
      keys = %w(id title users.username description location city country exposure elevation geo_lat geo_long created last_insert_datetime)
      sql = "SELECT #{keys.map{|k| "devices.#{k}"}.join(',').gsub('devices.users', 'users') }
              FROM devices LEFT OUTER JOIN users ON devices.user_id = users.id"
      records = MySQL.connection.execute(sql)
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