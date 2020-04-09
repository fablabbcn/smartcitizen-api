module V0
  class SensorsController < ApplicationController

    def show
      @sensor = Sensor.includes(:measurement).find(params[:id])
      authorize @sensor
    end

    def index
      @sensors = Sensor.includes(:measurement, :tag_sensors).all
      @sensors = paginate @sensors
    end

    def create
      @sensor = Sensor.new(sensor_params)
      authorize @sensor
      if @sensor.save
        render :show, status: :created
      else
        raise Smartcitizen::UnprocessableEntity.new @sensor.errors
      end
    end

    def update
      @sensor = Sensor.find(params[:id])
      authorize @sensor
      if @sensor.update(sensor_params)
        render :show, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @sensor.errors
      end
    end

private

    def sensor_params
      params.permit(
        :name,
        :description,
        :unit,
        :measurement_id
      )
    end

  end
end
