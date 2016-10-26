require 'securerandom'

module V0
  module Onboarding
    class OrphanDevicesController < VO::ApplicationController
      before_action :require_onboarding_session, except: :create

      def create
        orphan_device = OrphanDevice.new(orphan_device_params)
        orphan_device.device_token = SecureRandom.hex(3)

        if orphan_device.save
          render json: {
                          onboarding_session: SecureRandom.hex(10),
                          device_token: orphan_device.device_token
                        },
                 status: :created
        else
          render json: orphan_device.errors, status: :unprocessable_entity
        end
      end

      def update
        orphan_device = OrphanDevice.find_by(device_token: device_token)

        if orphan_device.update(orphan_device_params)
          render json: orphan_device, status: :ok
        else
          render json: orphan_device.errors, status: :unprocessable_entity
      end

      def find_user
        user = User.find_by(email: user_email)

        if user.nil?
          render json: { message: 'not_found' }, status: :not_found
        else
          render json: { username: user.username }, status: :ok
        end
      end

      private

      def require_onboarding_session
        params.require(:onboarding_session)
      end

      def orphan_device_params
        params.permit(:name, :description, :kit_id, :exposure, :latitude,
                      :longitude, :user_tags, :device_token)
      end

      def device_token
        params.require(:device_token)
      end

      def user_email
        params.require(:email)
      end
    end
  end
end
