module V0
  class MeController < ApplicationController

    # skip_after_action :verify_authorized
    before_action :check_if_authorized!
    # before_action :doorkeeper_authorize!

    def index
      @user = current_user
      render 'users/show'
    end

    def update
      @user = current_user
      authorize @user
      if @user.update_attributes(user_params)
        # head :no_content, status: :ok
        render 'users/show', status: :ok
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
        :url,
        :avatar
      )
    end

  end
end
