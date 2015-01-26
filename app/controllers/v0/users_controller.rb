module V0
  class UsersController < ApplicationController

    skip_before_action :doorkeeper_authorize!, only: [:index, :show, :create]

    def index
      @users = User.all
      render json: @users
    end

    def show
      @user = User.find(params[:id])
      render json: @user
    end

    def update
      @user = current_user
      if @user.update_attributes(user_params)
        head :no_content, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def create
      @user = User.new(user_params)
      if @user.save
        render json: @user, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

private

    def user_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :username,
        :password
      )
    end

  end
end
