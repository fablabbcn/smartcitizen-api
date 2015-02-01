module V0
  class PasswordResetsController < ApplicationController

    def create
      if user = User.find_by!(username: params.require(:username))
        user.send_password_reset
        render json: {message: 'Password Reset Instructions Delivered'}, status: :ok
      else
        render json: {message: 'User not found'}, status: :not_found
      end
    end

    def update
      @user = User.find_by!(password_reset_token: params[:id])
      if @user.update_attributes({ password: params.require(:password) })
        render json: @user, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

  end
end
