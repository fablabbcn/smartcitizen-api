module V0
  class UsersController < ApplicationController

    # before_action :check_if_authorized!, except: [:show, :create, :index]

    def show
      @user = User.includes(:sensors).friendly.find(params[:id])
      authorize @user
    end

    def index
      @q = User.includes(:devices, :profile_picture_attachment).ransack(params[:q])
      @q.sorts = 'id asc' if @q.sorts.empty?
      @users = @q.result(distinct: true)
      @users = paginate(@users)
    end

    def create
      @user = User.new(user_params)
      authorize @user
      if @user.save
        if Rails.env.test?
          UserMailer.welcome(@user.id).deliver_now
        else
          UserMailer.welcome(@user.id).deliver_later
        end
        render :show, status: :created
      else
        raise Smartcitizen::UnprocessableEntity.new @user.errors
      end
    end

    def update
      @user = User.includes(:sensors).friendly.find(params[:id])
      authorize @user
      if @user.update(user_params)
        render :show, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @user.errors
      end
    end

    def destroy
      @user = User.find(params[:id])
      authorize @user
      if @user.archive!
        render json: {message: 'OK'}, status: :ok
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
        :avatar,
        :avatar_url
      )
    end

  end
end

