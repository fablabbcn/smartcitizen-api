module V0
  class KitsController < ApplicationController

    def show
      @kit = Kit.includes(:sensors).friendly.find(params[:id])
      authorize @kit
      @kit
    end

    def index
      @kits = Kit.includes(:sensors)
      @kits = paginate(@kits)
    end

    def create
      @kit = Kit.new(kit_params)
      authorize @kit
      if @kit.save
        render :show, status: :created
      else
        raise Smartcitizen::UnprocessableEntity.new @kit.errors
      end
    end

    def update
      @kit = Kit.find(params[:id])
      authorize @kit
      if @kit.update_attributes(kit_params)
        render :show, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @kit.errors
      end
    end

private

    def kit_params
      params.permit(
        :name,
        :description,
        :slug,
        :sensor_map
      )
    end

  end
end
