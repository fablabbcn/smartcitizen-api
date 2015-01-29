module V0
  class UsersController < ApplicationController

    def index
      @users = User.all
      render json: @users
    end

    def show
      @user = User.friendly.find(params[:id])
      render json: @user
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
      params.permit(
        :first_name,
        :last_name,
        :email,
        :username,
        :password
      )
    end

  end
end
