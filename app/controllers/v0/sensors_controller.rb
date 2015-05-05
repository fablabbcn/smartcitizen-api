module V0
  class SensorsController < ApplicationController

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
        raise Smartcitizen::UnprocessableEntity.new @sensor.errors
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
