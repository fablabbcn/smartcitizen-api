module V0
  module Onboarding
    class OrphanDevicesController < ::V0::ApplicationController
      skip_after_action :verify_authorized
      before_action :set_orphan_device, only: [:update]

      rescue_from ActionController::ParameterMissing do
        render json: { error: 'Missing Params' }, status: :unprocessable_entity
      end

      def create
        @orphan_device = OrphanDevice.new(orphan_device_params)

        if save_orphan_device
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
        if @orphan_device.update(orphan_device_params)
          render json: @orphan_device, status: :ok
        else
          raise Smartcitizen::UnprocessableEntity.new @orphan_device.errors
        end
      end

      private

      def orphan_device_params
        params.permit(:name, :description, :kit_id, :exposure, :latitude, :longitude, :user_tags)
      end

      def onboarding_session
        params.require(:onboarding_session)
      end

      def set_orphan_device
        @orphan_device = OrphanDevice.find_by(onboarding_session: onboarding_session)
        render json: { error: 'Invalid onboarding_session' }, status: :not_found if @orphan_device.nil?
      end

      def save_orphan_device
      end
    end
  end
end
