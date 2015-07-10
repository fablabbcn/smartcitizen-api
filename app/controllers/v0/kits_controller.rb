module V0
  class KitsController < ApplicationController

    # before_action :check_if_authorized!, only: :update

    def index
      @kits = Kit.all
      @kits = paginate(@kits)
    end

    def show
      @kit = Kit.friendly.find(params[:id])
      authorize @kit
      @kit
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
        :slug
      )
    end

  end
end
