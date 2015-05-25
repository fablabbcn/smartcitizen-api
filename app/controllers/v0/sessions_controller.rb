module V0
  class SessionsController < ApplicationController

    def create
      user = User.find_by_username!(params[:username])
      authorize user, :show?
      if user && user.authenticate_with_legacy_support(params[:password])
        render json: { access_token: user.access_token!.token }, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new({
          message: {password: 'is incorrect'}
        })
      end
    end

  end
end