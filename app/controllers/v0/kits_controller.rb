module V0
  class KitsController < ApplicationController

    def index
      @kits = Kit.all
      @kits = paginate(@kits)
    end

    def show
      @kit = Kit.friendly.find(params[:id])
      authorize @kit
    end

  end
end
