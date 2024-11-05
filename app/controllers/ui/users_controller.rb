module Ui
  class UsersController < ApplicationController
    include SharedControllerMethods
    def index
      @title = I18n.t(:users_index_title)
    end

    def new
      @title = I18n.t(:new_user_title)
      @user = User.new
    end

    def create
      @user = User.new(params.require(:user).permit(
        :username,
        :email,
        :password,
        :password_confirmation,
        :ts_and_cs,
      ))
      if @user.valid?
        @user.save
        session[:user_id] = @user.id
        flash[:success] = I18n.t(:new_user_success)
        redirect_to ui_users_path
      else
        flash[:alert] = I18n.t(:new_user_failure)
        render :new, status: :unprocessable_entity
      end
    end
  end
end
