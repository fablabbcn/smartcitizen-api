module V0
  class PasswordResetsController < ApplicationController

    skip_after_action :verify_authorized, only: :create

    # 1/3 - A reset must be created with an authenticated request
    def create
      if params[:email].present?
        @user = User.where("lower(email) = lower(?)", params[:email]).first!
      elsif params[:username].present?
        @user = User.where("lower(username) = lower(?)", params[:username]).first!
      elsif e_o_u = params[:email_or_username]
        @user = User.where("lower(username) = lower(?) OR lower(email) = lower(?)", e_o_u, e_o_u).first!
      else
        raise Smartcitizen::UnprocessableEntity.new "Please include parameter email, username or email_or_username"
      end

      if @user
        authorize @user, :request_password_reset?
        @user.send_password_reset
      else
        raise Smartcitizen::UnprocessableEntity.new
      end

      render json: {message: 'Password Reset Instructions Delivered'}, status: :ok
    end

    # 2/3 - The associated user object is returned, indicating a valid token
    def show
      @user = User.find_by!(password_reset_token: params[:id])
      @current_user = @user
      authorize @user, :update_password?
      render 'users/show', status: :ok
    end

    # 3/3 - The password reset is submitted and committed to the database
    def update
      @user = User.find_by!(password_reset_token: params[:id])
      @current_user = @user
      authorize @user, :update_password?
      if @user.update({ password: params.require(:password), password_reset_token: nil })
        render 'users/show', status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @user.errors
      end
    end

  end
end
