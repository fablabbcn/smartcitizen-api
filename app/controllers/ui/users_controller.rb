module Ui
  class UsersController < ApplicationController
    include SharedControllerMethods

    PER_PAGE = 10

    def index
      redirect_to current_user ? ui_user_path(current_user.username) : login_path
    end

    def show
      find_user!
      @title = I18n.t(:show_user_title, owner: owner(true))
      add_breadcrumb(@title, ui_user_path(@user.username))
      @devices = @user.devices.for_user(current_user).by_last_reading.page(params[:device_page]).per(PER_PAGE)
      @experiments = @user.experiments.page(params[:experiment_page]).per(PER_PAGE)
    end

    def secrets
      find_user!
      return unless authorize_user! :show_secrets?, :secrets_user_forbidden
      @title = I18n.t(:secrets_user_title, owner: owner(true))
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: owner(true)), ui_user_path(@user.username)],
        [I18n.t(:secrets_breadcrumb), secrets_ui_user_path(@user.username)]
      )
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
        :preferred_time_zone,
        :ts_and_cs,
      ))
      if @user.valid?
        @user.save
        session[:user_id] = @user.id
        flash[:success] = I18n.t(:new_user_success)
        redirect_to goto_or(ui_user_path(@user.username))
      else
        flash[:alert] = I18n.t(:new_user_failure)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      find_user!
      return unless authorize_user! :update?, :edit_user_forbidden
      @title = I18n.t(:edit_user_title, owner: owner)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: owner(true)), ui_user_path(@user.username)],
        [I18n.t(:edit_breadcrumb), edit_ui_user_path(@user.username)]
      )
    end

    def update
      find_user!
      return unless authorize_user! :update?, :edit_user_forbidden
      if @user.update(user_params)
        flash[:success] = I18n.t(:update_user_success)
        redirect_to ui_user_path(@user.username)
      else
        flash[:alert] = I18n.t(:update_user_failure)
        render :edit, status: :unprocessable_entity
      end
    end

    def delete
      find_user!
      return unless authorize_user! :destroy?, :delete_user_forbidden
      @title = I18n.t(:delete_user_title, owner: owner)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: owner(true)), ui_user_path(@user.username)],
        [I18n.t(:edit_breadcrumb), edit_ui_user_path(@user.username)],
        [I18n.t(:delete_breadcrumb), delete_ui_user_path(@user.username)]
      )
    end

    def destroy
      find_user!
      return unless authorize_user! :destroy?, :delete_user_forbidden
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

    def user_params
      params.require(:user).permit(
        :profile_picture,
        :username,
        :email,
        :password,
        :password_confirmation,
        :city,
        :country_code,
        :url,
        :preferred_time_zone
      )
    end

    def find_user!
      @user = User.friendly.find(params[:id])
    end

    def authorize_user!(action, alert)
      return true if authorize? @user, action
      flash[:alert] = I18n.t(alert)
      redirect_to current_user ? ui_user_path(@user) : login_path
      return false
    end

    def owner(capitalize=false)
      helpers.possessive(@user, current_user, capitalize: capitalize, third_person: true)
    end
  end
end
