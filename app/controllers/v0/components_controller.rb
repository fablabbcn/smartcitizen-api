module V0
  class ComponentsController < ApplicationController

    def index
      @components = Component.all
      paginate json: @components
    end

  end
end
