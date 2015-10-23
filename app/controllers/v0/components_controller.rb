module V0
  class ComponentsController < ApplicationController

    def index
      @components = Component.all
      @components = paginate(@components)
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
