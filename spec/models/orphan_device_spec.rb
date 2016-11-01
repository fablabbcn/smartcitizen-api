require 'rails_helper'

RSpec.describe OrphanDevice, type: :model do
  let(:orphan_device) { create(:orphan_device, device_token: 'aA5555') }

  describe 'device_token' do
    describe '.generate_token!' do
      it 'generates random 6 character device_token' do
        orphan_dev = build(:orphan_device)

        expect(orphan_dev.device_token).to eq(nil)
        orphan_dev.generate_token!
        expect(orphan_dev.device_token.nil?).to eq(false)
        expect(orphan_dev.device_token.length).to eq(6)
      end

      before do
        allow(SecureRandom).to receive(:hex).with(3).and_return('aA5555')
      end

      it { is_expected.to validate_uniqueness_of(:device_token) }
      it { is_expected.not_to allow_value(nil).for(:device_token) }
    end

    it 'is readonly' do
      orphan_device.update(device_token: '555555')

      orphan_device.reload

      expect(orphan_device.device_token).not_to eq('555555')
      expect(orphan_device.device_token_was).to eq(orphan_device.device_token)
    end
  end

  describe 'onboarding_session' do
    it { is_expected.not_to allow_value(nil).for(:onboarding_session) }

    it 'generates uuid onboarding_session after_initialize' do
      expect(build(:orphan_device).onboarding_session).not_to eq(nil)
    end

    it 'is readonly' do
      orphan_device.update(onboarding_session: '123123')

      orphan_device.reload

      expect(orphan_device.onboarding_session).not_to eq('123123')
      expect(orphan_device.onboarding_session_was).to eq(orphan_device.onboarding_session)
    end
  end

  describe '.device_attributes' do
    it 'attributes hash without device_token and onboarding_session' do
      device_attributes_hash = orphan_device.device_attributes

      expect(device_attributes_hash.length).to eq(8)
      expect(device_attributes_hash.key?(:name)).to eq(true)
      expect(device_attributes_hash.key?(:kit_id)).to eq(true)
      expect(device_attributes_hash.key?(:description)).to eq(true)
      expect(device_attributes_hash.key?(:user_tags)).to eq(true)
      expect(device_attributes_hash.key?(:longitude)).to eq(true)
      expect(device_attributes_hash.key?(:latitude)).to eq(true)
      expect(device_attributes_hash.key?(:exposure)).to eq(true)
      expect(device_attributes_hash.key?(:device_token)).to eq(true)
    end
  end
end
