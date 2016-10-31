require 'rails_helper'

RSpec.describe V0::Onboarding::OrphanDevicesController, type: :controller do
  it { is_expected.to permit(:name, :description, :kit_id, :exposure, :latitude, :longitude,
                             :user_tags).for(:create) }

  describe "save_orphan_device" do
    before do
      @controller = V0::Onboarding::OrphanDevicesController.new
      @controller.params = ActionController::Parameters.new

      allow(SecureRandom).to receive(:hex).with(3).and_return('123123')
      create(:orphan_device, device_token: '123123')
    end

    it 'tries 10 times generating_token & saving it' do
      expect(@controller).to receive(:raise)
      @controller.send(:create)
      expect(@controller.instance_variable_get('@attempts')).to eq(10)
      orphan_dev = controller.instance_variable_get('@orphan_device')
      expect(orphan_dev.errors.messages[:device_token][0]).to eq('has already been taken')
    end
  end
end
