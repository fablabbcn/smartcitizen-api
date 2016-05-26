module V0
  class ComponentsController < ApplicationController

    def index
      @components = Component.all
      @components = paginate(@components)
    end

    def show
      @component = Component.includes(:board, :sensor).find(params[:id])
      authorize @component
    end

private

    def component_params
      params.permit(
        :board_id,
        :board_type,
        :sensor_id,
        :equation
      )
    end

  end
end
