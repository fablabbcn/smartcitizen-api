module V0
  class TagsController < ApplicationController

    def show
      @tag = Tag.friendly.find(params[:id])
      authorize @tag
    end

    def index
      @tags = Tag.all
      @tags = paginate @tags
    end

    def create
      @tag = Tag.new(tag_params)
      authorize @tag
      if @tag.save
        render :show, status: :created
      else
        raise Smartcitizen::UnprocessableEntity.new @tag.errors
      end
    end

    def update
      @tag = Tag.find(params[:id])
      authorize @tag
      if @tag.update_attributes(tag_params)
        render :show, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @tag.errors
      end
    end

    def destroy
      @tag = Tag.find(params[:id])
      authorize @tag
      if @tag.destroy
        render json: {message: 'OK'}, status: :ok
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
