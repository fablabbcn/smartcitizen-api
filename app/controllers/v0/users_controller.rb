module V0
  class UsersController < ApplicationController

    swagger_controller :users, "Users"
    swagger_api :index do
      summary "Fetches all User items"
      notes "This lists all the active users"

      param :query, :page, :integer, :required, "Page number"
      param :query, :per_page, :integer, :optional, "Per Page", { defaultValue: 1 }


      response :unauthorized
      response :not_acceptable
      response :requested_range_not_satisfiable
    end


    def index
      @q = User.includes(:devices).ransack(params[:q])
      @q.sorts = 'id asc' if @q.sorts.empty?
      @users = @q.result(distinct: true)
      paginate json: @users
    end

    def show
      # begin
      @user = User.includes(:sensors).friendly.find(params[:id])
      authorize @user
      render json: @user, serializer: DetailedUserSerializer
      # rescue ActiveRecord::RecordNotFound
      #   render json: {message: "No user found with username or id '#{params[:id]}'"}, status: :not_found
      # end
    end

    def create
      @user = User.new(user_params)
      authorize @user
      if @user.save
        UserMailer.welcome(@user).deliver_now
        render json: @user, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      @user = User.includes(:sensors).friendly.find(params[:id])
      authorize @user
      if @user.update_attributes(user_params)
        render json: @user, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

private

    def user_params
      params.permit(
        :first_name,
        :last_name,
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
