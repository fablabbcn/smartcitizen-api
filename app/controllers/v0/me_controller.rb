module V0
  class MeController < ApplicationController

    before_action :check_if_authorized!

    def index
      @user = current_user
      render 'users/show'
    end

    def update
      @user = current_user
      authorize @user
      if @user.update_attributes(user_params)
        render 'users/show', status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @user.errors
      end
    end

    def profile_url
      authorize current_user, :update?
      render json: {'profile': url_for(current_user.profile_picture.service_url)}, status: :ok
    end

    def destroy
      @user = current_user
      authorize @user
      if @user.archive!
        render json: {message: 'OK'}, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @user.errors
      end
    end

private

    def user_params
      params.permit(
        :email,
        :username,
        :password,
        :city,
        :country_code,
        :profile_picture,
        :url,
        :avatar,
        :avatar_url
      )
    end

  end
end
