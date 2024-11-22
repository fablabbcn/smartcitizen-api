module Ui
  class UsersController < ApplicationController
    include SharedControllerMethods

    def index
      @title = I18n.t(:users_index_title)
    end

    def new
      if current_user
        flash[:alert] = I18n.t(:new_user_not_allowed_for_logged_in_users)
        redirect_to ui_users_path
        return
      end
      @title = I18n.t(:new_user_title)
      @user = User.new
    end

    def create
      if current_user
        flash[:alert] = I18n.t(:new_user_not_allowed_for_logged_in_users)
        redirect_to ui_users_path
        return
      end
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
    def delete
      @user = User.find(params[:id])
      unless authorize? @user, :destroy?
        flash[:alert] = I18n.t(:delete_user_forbidden)
        redirect_to current_user ? ui_users_path : login_path
        return
      end
      @title = I18n.t(:delete_user_title)
    end

    def destroy
      @user = User.find(params[:id])
      unless authorize? @user
        flash[:alert] = I18n.t(:delete_user_forbidden)
        redirect_to current_user ? ui_users_path : login_path
        return
      end
      if @user.username != params[:username]
        flash[:alert] = I18n.t(:delete_user_wrong_username)
        redirect_to delete_ui_user_path(@user.id)
        return
      end
      @user.archive!
      session[:user_id] = nil
      redirect_to post_delete_ui_users_path
    end

    def post_delete
      @title = I18n.t(:post_delete_user_title)
    end
  end
end
