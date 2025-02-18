module Ui
  class SessionsController < ApplicationController
    include SharedControllerMethods
    require 'uri'
    require 'net/http'
    require 'net/https'

    def new
      @title = I18n.t(:new_session_title)
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
          flash[:success] = I18n.t(:new_session_success)
          redirect_to goto_or(session[:user_return_to] || ui_users_path)
        end
      else
        flash.now.alert = I18n.t(:new_session_failure)
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
      flash[:notice] = I18n.t(:password_reset_notice)
    end

    def password_reset_landing
      @title = I18n.t(:password_reset_landing_title)
      @token = params[:token]
    end

    def change_password
      @token = params.require(:token)

      if params.require(:password) != params.require(:password_confirmation)
        flash[:alert] = I18n.t(:password_reset_failure)
        render "password_reset_landing"
        return
      end

      @user = User.find_by(password_reset_token: @token)
      if @user
        authorize @user, :update_password?
        @user.update(params.permit(:password, :password_confirmation).merge(password_reset_token: nil))
        flash[:success] = I18n.t(:password_reset_success, username: @user.username)
        redirect_to new_ui_session_path
      else
        flash[:alert] = I18n.t(:password_reset_invalid)
        render "password_reset_landing"
      end
    end

    def destroy
      session[:user_id] = nil
      redirect_to goto_or(login_url), notice: I18n.t(:destroy_session_success)
    end
  end
end
