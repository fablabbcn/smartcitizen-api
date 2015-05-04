module V0
  class MeController < ApplicationController

    # skip_after_action :verify_authorized
    before_action :check_if_authorized!
    # before_action :doorkeeper_authorize!

    def index
      @user = current_user
      render json: @user
    end

    def update
      @user = current_user
      authorize @user
      if @user.update_attributes(user_params)
        # head :no_content, status: :ok
        render json: @user, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

private

    def user_params
      params.permit(
        :first_name,
        :last_name,
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
