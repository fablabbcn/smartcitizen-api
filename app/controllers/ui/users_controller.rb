module Ui
  class UsersController < ApplicationController
    include SharedControllerMethods

    def index
      redirect_to current_user ? ui_user_path(current_user.username) : login_path
    end

    def show
      find_user!
      @title = I18n.t(:show_user_title, username: @user.username)
      render "show", layout: "base"
    end

    def secrets
      find_user!
      return unless authorize_user!
      @title = I18n.t(:secrets_user_title, username: @user.username)
    end

    def new
      if current_user
        flash[:alert] = I18n.t(:new_user_not_allowed_for_logged_in_users)
        redirect_to ui_user_path(current_user.username)
        return
      end
      @title = I18n.t(:new_user_title)
      @user = User.new
    end

    def create
      if current_user
        flash[:alert] = I18n.t(:new_user_not_allowed_for_logged_in_users)
        redirect_to ui_user_path(current_user.username)
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
        redirect_to ui_user_path(@user.username)
      else
        flash[:alert] = I18n.t(:new_user_failure)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      find_user!
      return unless authorize_user!
      @title = I18n.t(:edit_user_title)
    end

    def update
      find_user!
      return unless authorize_user!
      if @user.update(params.require(:user).permit(
        :profile_picture,
        :username,
        :email,
        :password,
        :password_confirmation,
        :city,
        :country_code,
        :url
      ))
        flash[:success] = I18n.t(:update_user_success)
        redirect_to ui_user_path(@user.username)
      else
        flash[:alert] = I18n.t(:update_user_failure)
        render :new, status: :unprocessable_entity
      end
    end

    def delete
      find_user!
      return unless authorize_user!
      @title = I18n.t(:delete_user_title)
    end

    def destroy
      find_user!
      return unless authorize_user!
      if @user.username != params[:username]
        flash[:alert] = I18n.t(:delete_user_wrong_username)
        redirect_to delete_ui_user_path(@user.username)
        return
      end
      @user.archive!
      session[:user_id] = nil
      redirect_to post_delete_ui_users_path
    end

    def post_delete
      @title = I18n.t(:post_delete_user_title)
    end

    private

    def find_user!
      @user = User.friendly.find(params[:id])
    end

    def authorize_user!
      return true if authorize? @user, :destroy?
      flash[:alert] = I18n.t(:delete_user_forbidden)
      redirect_to current_user ? ui_user_path(@user) : login_path
      return false
    end
  end
end
