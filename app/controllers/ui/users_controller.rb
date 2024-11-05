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
      @user = User.create(params.permit(
        :username,
        :email,
        :password,
        :password_confirmation,
        :ts_and_cs,
      ))
      session[:user_id] = @user.id
      flash[:success] = I18n.t(:new_user_success)
      redirect_to ui_users_path
    end
  end
end
