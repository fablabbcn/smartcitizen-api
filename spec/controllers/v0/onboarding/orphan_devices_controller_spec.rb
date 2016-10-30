require 'rails_helper'

RSpec.describe V0::Onboarding::OrphanDevicesController, type: :controller do
  it { is_expected.to permit(:name, :description, :kit_id, :exposure, :latitude, :longitude,
                             :user_tags).for(:create) }

  describe 'orphan_device_params for update' do
    before do
      params = {
        name: nil,
        description: nil,
        kit_id: nil,
        exposure: nil,
        latitude: nil,
        longitude: nil,
        user_tags: nil,

        onboarding_session: nil
      }
      @controller_params = ActionController::Parameters.new(params)
      @device_params = ActionController::Parameters.new(params.except!(:onboarding_session))
    end

    it 'does not include onboarding_session' do
      controller = V0::Onboarding::OrphanDevicesController.new
      controller.params = @controller_params
      expect(controller.send(:orphan_device_params)).to eq(@device_params)
    end
  end
end
