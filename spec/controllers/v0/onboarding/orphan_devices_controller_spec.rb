require 'rails_helper'

RSpec.describe V0::Onboarding::OrphanDevicesController, type: :controller do
  it { is_expected.to permit(:name, :description, :kit_id, :exposure, :latitude, :longitude,
                             :user_tags).for(:create) }

  describe "save_orphan_device" do
    before do
      @controller = V0::Onboarding::OrphanDevicesController.new
      @controller.params = ActionController::Parameters.new

      allow_any_instance_of(OrphanDevice).to receive(:generate_token).and_raise(ActiveRecord::RecordInvalid.new(OrphanDevice.new))
    end

    it 'tries 10 times generating_token & saving it' do
      expect(@controller).to receive(:raise).with(Smartcitizen::UnprocessableEntity.new)
      expect_any_instance_of(OrphanDevice).to receive(:generate_token).exactly(10).times
      @controller.send(:create)
    end
  end
end
