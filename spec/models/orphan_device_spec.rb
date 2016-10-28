require 'rails_helper'

RSpec.describe OrphanDevice, type: :model do
  it { is_expected.to validate_uniqueness_of(:device_token) }

  before do
    @orphan_device = create(:orphan_device)
  end

  describe 'device_token' do
    it 'generates 6 character device_token after_create' do
      expect(build(:orphan_device).device_token.nil?).to eq(true)
      expect(@orphan_device.device_token.nil?).to eq(false)
      expect(@orphan_device.device_token.length).to eq(6)
    end

    it 'does not allow updating device_token' do
      @orphan_device.update(device_token: '555555')

      @orphan_device.reload

      expect(@orphan_device.device_token).not_to eq('555555')
      expect(@orphan_device.device_token_was).to eq(@orphan_device.device_token)

      expect(@orphan_device.errors.messages[:device_token][0]).to eq('cannot be changed')
    end
  end
end
