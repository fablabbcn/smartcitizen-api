module V0
  class MeasurementsController < ApplicationController

    before_action :set_measurement, only: [:show, :update, :destroy]

    def show
      authorize @measurement
    end

    def index
      @measurements = Measurement.all
      @measurements = paginate @measurements
    end

    def create
      @measurement = Measurement.new(measurement_params)
      authorize @measurement
      if @measurement.save
        render :show, status: :created
      else
        raise Smartcitizen::UnprocessableEntity.new @measurement.errors
      end
    end

    def update
      authorize @measurement
      if @measurement.update_attributes(measurement_params)
        render :show, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @measurement.errors
      end
    end

private

    def measurement_params
      params.permit( :name, :description, :unit )
    end

    def set_measurement
      @measurement = Measurement.find(params[:id])
    end

  end
end
