module V0
  class UsersController < ApplicationController

    def index
      @users = User.includes(:devices).all
      if ['created_at', 'username'].include?(params[:order])
        if ['asc', 'desc'].include?(params[:direction])
          @users = @users.order([params[:order],params[:direction]].join(' '))
        else
          @users = @users.order(params[:order])
        end
      end
      paginate json: @users
    end

    def show
      # begin
      @user = User.includes(:sensors).friendly.find(params[:id])
      authorize @user
      render json: @user, serializer: DetailedUserSerializer
      # rescue ActiveRecord::RecordNotFound
      #   render json: {message: "No user found with username or id '#{params[:id]}'"}, status: :not_found
      # end
    end

    def create
      @user = User.new(user_params)
      authorize @user
      if @user.save
        UserMailer.welcome(@user).deliver_now
        render json: @user, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      @user = User.includes(:sensors).friendly.find(params[:id])
      authorize @user
      if @user.update_attributes(user_params)
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
