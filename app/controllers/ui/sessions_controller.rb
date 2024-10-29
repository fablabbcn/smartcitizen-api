module Ui
  class SessionsController < ApplicationController
    include SharedControllerMethods
    require 'uri'
    require 'net/http'
    require 'net/https'

    def new
      redirect_to ui_users_url if current_user
    end

    def index
      redirect_to new_ui_session_path
    end

    def create
      if params[:send_password_email]
        reset_password_email
        redirect_to new_ui_session_path
        return
      end

      user = User.where("lower(email) = lower(?) OR lower(username) = lower(?)",
                        params[:username_or_email], params[:username_or_email]).first
      if user && user.authenticate_with_legacy_support(params[:password])
        session[:user_id] = user.id

        if params[:goto].include? 'discourse'
          redirect_to session[:discourse_url]
        else
          flash[:success] = "You have been successfully logged in!"
          redirect_to (session[:user_return_to] || ui_users_path)
        end
      else
        flash.now.alert = "Email or password is invalid"
        render "new"
      end
    end

    def reset_password_email
      user = User.where("lower(email) = lower(?) OR lower(username) = lower(?)",
                        params[:username_or_email], params[:username_or_email]).first

      if user
        authorize user, :request_password_reset?
        user.send_password_reset
      end
      flash[:notice] = 'Please check your email to reset the password.'
    end

    def password_reset_landing
      @token = params[:token]
    end

    def change_password
      @token = params.require(:token)

      if params.require(:password) != params.require(:password_confirmation)
        flash[:alert] ="Your password doesn't match the confirmation"
        render "password_reset_landing"
        return
      end

      @user = User.find_by(password_reset_token: @token)
      if @user
        authorize @user, :update_password?
        @user.update({ password: params.require(:password), password_reset_token: nil })
        flash[:success] = "Changed password for: #{@user.username}"
        redirect_to new_ui_session_path
      else
        flash[:alert] = 'Your reset code might be too old or have been used before.'
        render "password_reset_landing"
      end
    end

    def destroy
      session[:user_id] = nil
      redirect_to login_url, notice: "Logged out!"
    end
  end
end
