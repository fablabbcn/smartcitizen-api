module V0
  module Onboarding
    class RegistrationsController < ::ApplicationController
      def find_user
        user = User.find_by(email: user_email)

        if user.nil?
          render json: { message: 'not_found' }, status: :not_found
        else
          render json: { username: user.username }, status: :ok
        end
      end

      def login
        # user authenticates
        # create device from orphan_device
        # add user to newly created device || add newly created device to user
      end

      prviate

      def user_email
        params.require(:email)
      end
    end
  end
end
