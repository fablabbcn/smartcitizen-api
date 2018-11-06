module V0
  class TagSensorsController < ApplicationController

    def index
      @tags = TagSensor.all
      @tags = paginate @tags
    end

    def show
      @tag = TagSensor.find(params[:id])
      authorize @tag
    end

    def create
      @tag = TagSensor.new(tag_params)
      authorize @tag
      if @tag.save
        render :show, status: :created
      else
        raise Smartcitizen::UnprocessableEntity.new @tag.errors
      end
    end

private

    def tag_params
      params.permit(
        :name,
        :description
      )
    end

  end
end
