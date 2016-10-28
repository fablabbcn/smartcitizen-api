module V0
  module Onboarding
    class DeviceRegistrationsController < ::V0::ApplicationController
      before_action :require_params, only: [:find_user]
      before_action :set_orphan_device

      skip_after_action :verify_authorized, only: [:find_user]

      rescue_from ActionController::ParameterMissing do
        render json: { error: 'Missing Params' }, status: :unprocessable_entity
      end

      def find_user
        user = User.find_by(email: params[:email])

        @orphan_device.update(owner_email: params[:email])
        if user.nil?
          render json: { message: 'not_found' }, status: :not_found
        else
          render json: { username: user.username }, status: :ok
        end
      end

      def register_device
        # maybe could call
        #  ::DevicesController.new.create(@orphan_device.device_attributes)
        puts current_user
        # device = current_user.devices.build(@orphan_device.device_attributes)
        #
        # authorize device
        #
        # if device.save
        #   render json: device, status: :created
        # else
        #   raise Smartcitizen::UnprocessableEntity.new device.errors
        # end
      end

      private

      def require_params
        params.permit(:email, :onboarding_session, :access_token).tap do |parameters|
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
