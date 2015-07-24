module V0
  class UsersController < ApplicationController

    before_action :check_if_authorized!, only: :update

    def index
      @q = User.includes(:devices).ransack(params[:q])
      @q.sorts = 'id asc' if @q.sorts.empty?
      @users = @q.result(distinct: true)
      @users = paginate(@users)
    end

    def show
      @user = User.includes(:sensors).friendly.find(params[:id])
      authorize @user
    end

    def create
      @user = User.new(user_params)
      authorize @user
      if @user.save
        UserMailer.welcome(@user).deliver_now
        render :show, status: :created
      else
        raise Smartcitizen::UnprocessableEntity.new @user.errors
      end
    end

    def update
      @user = User.includes(:sensors).friendly.find(params[:id])
      authorize @user
      if @user.update_attributes(user_params)
        render :show, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @user.errors
      end
    end

private

    def user_params
      params.permit(
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

