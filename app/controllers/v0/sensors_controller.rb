module V0
  class SensorsController < ApplicationController

    def index
      @sensors = Sensor.all
      @sensors = paginate @sensors
    end

    def show
      @sensor = Sensor.find(params[:id])
      authorize @sensor
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
      if @sensor.update_attributes(sensor_params)
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
        :unit
      )
    end

  end
end
