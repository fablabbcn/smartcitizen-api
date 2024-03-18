module V0
  class ComponentsController < ApplicationController

    def index
      @components = Component.all
      @components = paginate(@components)
    end

    def show
      @component = Component.includes(:device, :sensor).find(params[:id])
      authorize @component
    end

private

    def component_params
      params.permit(
        :device_id,
        :sensor_id
      )
    end

  end
end
