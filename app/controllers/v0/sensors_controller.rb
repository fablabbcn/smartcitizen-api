module V0
  class SensorsController < ApplicationController

    swagger_controller :sensors, "Sensors"
    swagger_api :index do
      summary "Fetches all User items"
      notes "This lists all the active users"
      param :query, :page, :integer, :optional, "Page number"
      response :unauthorized
      response :not_acceptable
      response :requested_range_not_satisfiable
    end

    def index
      @sensors = Sensor.all
      paginate json: @sensors
    end

    def show
      @sensor = Sensor.find(params[:id])
      authorize @sensor
      render json: @sensor
    end

    def create
      @sensor = Sensor.new(sensor_params)
      authorize @sensor
      if @sensor.save
        render json: @sensor, status: :created
      else
        render json: { errors: @sensor.errors.full_messages }, status: :unprocessable_entity
      end
    end

private

    def sensor_params
      params.permit(
        :name,
        :description,
        :unit
      )
    end

  end
end
