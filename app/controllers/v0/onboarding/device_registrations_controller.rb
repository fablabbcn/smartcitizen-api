module V0
  module Onboarding
    class DeviceRegistrationsController < ApplicationController
      before_action :set_orphan_device, only: :register_device
      before_action :check_if_authorized!, only: :register_device
      after_action :verify_authorized, only: :register_device

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

        authorize device, :create?

        if device.save
          render json: device, status: :created
        else
          raise Smartcitizen::UnprocessableEntity.new device.errors
        end
      end

      def find_username
        render json: {message: (User.exists?(username: params.permit(:username).require(:username)) ? 'found' : 'not_found')}, status: :ok
      end

      private

      def user_email
        params.permit(:email).require(:email)
      end


      def set_orphan_device
        @orphan_device = OrphanDevice.find_by(
          onboarding_session: request.headers['HTTP_ONBOARDINGSESSION']
        )
        render json: { error: 'Invalid OnboardingSession' }, status: :not_found if @orphan_device.nil?
      end
    end
  end
end
