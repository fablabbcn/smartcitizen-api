module V0
  module Onboarding
    class OrphanDevicesController < ::ApplicationController
      before_action :require_onboarding_session, only: [:update]

      rescue_from ActionController::ParameterMissing do
        render json: { error: 'Missing Params' }, status: :unprocessable_entity
      end

      def create
        orphan_device = OrphanDevice.new(orphan_device_params)

        if orphan_device.save
          render json: {
                          onboarding_session: orphan_device.onboarding_session,
                          device_token: orphan_device.device_token
                        },
                 status: :created
        else
          raise Smartcitizen::UnprocessableEntity.new orphan_device.errors
        end
      end

      def update
        orphan_device = OrphanDevice.find_by(device_token: device_token)

        return device_not_found if orphan_device.nil?

        if orphan_device.update(orphan_device_params)
          render json: orphan_device, status: :ok
        else
          raise Smartcitizen::UnprocessableEntity.new orphan_device.errors
        end
      end

      private

      def orphan_device_params
        params.permit(:name, :description, :kit_id, :exposure,
                      :latitude, :longitude, :user_tags)
      end

      def device_token
        params.require(:device_token)
      end

      def require_onboarding_session
        params.require(:onboarding_session)
      end

      def device_not_found
        render json: { error: 'Invalid device_token' }, status: :not_found
      end
    end
  end
end
