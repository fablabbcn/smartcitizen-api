module V0
  class SessionsController < ApplicationController

    def create
      check_missing_params("username", "password")
      user = User.find_by_username!(params[:username])
      authorize user, :show?
      if user && user.authenticate_with_legacy_support(params[:password])
        # $analytics.track("login:successful", user.id)
        # Minuteman.track("login:successful", user)
        Minuteman.add("logins")
        render json: { access_token: user.access_token!.token }, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new({
          message: {password: 'is incorrect'}, # to be removed
          password: 'is incorrect' # to replace the above
        })
      end
    end

  end
end