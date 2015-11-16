module V0
  class ComponentsController < ApplicationController

    def index
      @components = Component.all
      @components = paginate(@components)
    end

  end
end
