require 'rails_helper'

RSpec.describe OrphanDevice, type: :model do
  let(:orphan_device) { create(:orphan_device) }

  describe 'device_token' do
    describe '.generate_device_token' do
      before do
        allow(SecureRandom).to receive(:hex).with(3).and_return('aA5555')
        create(:orphan_device)
      end

      it { is_expected.to validate_uniqueness_of(:device_token) }

      it 'calls generate_device_token' do
        orphan_dev = build(:orphan_device)
        expect(orphan_dev).to receive(:generate_device_token).once
        orphan_dev.save!
      end

      it 'attempts 10 times to assign device_token before throwing exception' do
        orphan_dev = build(:orphan_device)
        expect { orphan_dev.save! }.to raise_error(ActiveRecord::RecordInvalid)
        expect(orphan_dev.instance_variable_get('@attempts')).to eq(10)
        expect(orphan_dev.errors.messages[:device_token][0]).to eq('has already been taken')
      end
    end

    it 'generates 6 character device_token after_create' do
      expect(build(:orphan_device).device_token.nil?).to eq(true)
      expect(orphan_device.device_token.nil?).to eq(false)
      expect(orphan_device.device_token.length).to eq(6)
    end

    it 'acts as readonly' do
      orphan_device.update(device_token: '555555')

      orphan_device.reload

      expect(orphan_device.device_token).not_to eq('555555')
      expect(orphan_device.device_token_was).to eq(orphan_device.device_token)

      expect(orphan_device.errors.messages[:device_token][0]).to eq('cannot be changed')
    end
  end

  describe 'onboarding_session' do
    it { is_expected.to validate_uniqueness_of(:onboarding_session) }

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

      expect(device_attributes_hash.length).to eq(7)
      expect(device_attributes_hash.key?(:name)).to eq(true)
      expect(device_attributes_hash.key?(:kit_id)).to eq(true)
      expect(device_attributes_hash.key?(:description)).to eq(true)
      expect(device_attributes_hash.key?(:user_tags)).to eq(true)
      expect(device_attributes_hash.key?(:longitude)).to eq(true)
      expect(device_attributes_hash.key?(:latitude)).to eq(true)
      expect(device_attributes_hash.key?(:exposure)).to eq(true)
    end
  end
end
