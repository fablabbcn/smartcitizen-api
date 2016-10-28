module V0
  module Onboarding
    class RegistrationsController < ::ApplicationController
      before_action :require_params, only: [:find_user]
      before_action :set_orphan_device

      rescue_from ActionController::ParameterMissing do
        render json: { error: 'Missing Params' }, status: :unprocessable_entity
      end

      def find_user
        user = User.find_by(email: params[:email])

        # @orphan_device.update(owner_email: params[:email]) regardless ?
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

      private

      def require_params
        params.permit(:email, :onboarding_session).tap do |parameters|
          parameters.require(:onboarding_session)
          parameters.require(:email)
        end
      end

      def set_orphan_device
        @orphan_device = OrphanDevice.find_by(onboarding_session: params[:onboarding_session])
        render json: { error: 'Invalid onboarding_session' }, status: :not_found if @orphan_device.nil?
      end
    end
  end
end
