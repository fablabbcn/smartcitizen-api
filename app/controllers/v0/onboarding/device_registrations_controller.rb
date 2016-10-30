module V0
  module Onboarding
    class DeviceRegistrationsController < ::V0::ApplicationController
      before_action :require_params, only: :find_user
      before_action :set_orphan_device, only: :register_device

      skip_after_action :verify_authorized

      rescue_from ActionController::ParameterMissing do
        render json: { error: 'Missing Params' }, status: :unprocessable_entity
      end

      def find_user
        user = User.find_by(email: user_email)

        if user.nil?
          render json: { message: 'not_found' }, status: :not_found
        else
          render json: { username: user.username }, status: :ok
        end
      end

      def register_device
        device = current_user.devices.build(@orphan_device.device_attributes)

        if device.save
          render json: device, status: :created
        else
          raise Smartcitizen::UnprocessableEntity.new device.errors
        end
      end

      private

      def user_email
        params.require(:email)
      end

      def set_orphan_device
        @orphan_device = OrphanDevice.find_by(
          onboarding_session: request.headers['HTTP_ONBOARDING_SESSION']
        )
        render json: { error: 'Invalid onboarding_session' }, status: :not_found if @orphan_device.nil?
      end
    end
  end
end
