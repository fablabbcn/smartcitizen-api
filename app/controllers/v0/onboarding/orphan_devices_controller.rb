module V0
  module Onboarding
    class OrphanDevicesController < ApplicationController
      skip_after_action :verify_authorized
      before_action :set_orphan_device, only: :update

      def show
        @orphan_device = OrphanDevice.find_by(
          onboarding_session: request.headers['HTTP_ONBOARDINGSESSION']
        )

        # TODO: add test using the request.headers
        if @orphan_device.nil?
          render json: { error: 'Invalid OnboardingSession' }, status: :not_found
        else
          render json: @orphan_device, status: :ok
        end

      end

      def create
        @orphan_device = OrphanDevice.new(orphan_device_params)

        if save_orphan_device
          render json: {
                          onboarding_session: @orphan_device.onboarding_session,
                          device_token: @orphan_device.device_token
                        },
                 status: :created
        else
          raise Smartcitizen::UnprocessableEntity.new @orphan_device.errors
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

      def set_orphan_device
        @orphan_device = OrphanDevice.find_by(
          onboarding_session: request.headers['HTTP_ONBOARDINGSESSION']
        )
        render json: { error: 'Invalid OnboardingSession' }, status: :not_found if @orphan_device.nil?
      end

      def save_orphan_device
        @orphan_device.generate_token!
        return false unless @orphan_device.valid?
        @orphan_device.save!
      rescue ActiveRecord::RecordInvalid => e
        attempts = attempts.to_i + 1
        retry if attempts < 10
        false
      end
    end
  end
end
