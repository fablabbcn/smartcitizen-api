module V0
  class UsersController < ApplicationController

    def index
      @users = User.all
      paginate json: @users
    end

    def show
      begin
        @user = User.includes(:sensors).friendly.find(params[:id])
        render json: @user
      rescue ActiveRecord::RecordNotFound
        render json: {message: "No user found with username or id '#{params[:id]}'"}, status: :not_found
      end
    end

    def create
      @user = User.new(user_params)
      if @user.save
        UserMailer.welcome(@user).deliver_now
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
