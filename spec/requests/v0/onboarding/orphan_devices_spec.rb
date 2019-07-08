require 'rails_helper'

describe V0::Onboarding::OrphanDevicesController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }
  let(:device) { create(:device) }
  let(:orphan_device) { create(:orphan_device, device_token: 'aA1234') }

  before(:each) do
    # Prevent throttle
    Rails.cache.clear
  end

  describe 'POST /onboarding/device' do
    it 'returns onboarding_session and device_token of created orphan_device' do
      j = api_post '/onboarding/device'

      orphan_device = OrphanDevice.first
      expect(response.status).to eq(201)
      expect(OrphanDevice.count).to eq(1)

      expect(j['device_token']).to eq(orphan_device.device_token)
      expect(j['onboarding_session']).to eq(orphan_device.onboarding_session)
    end

    it 'creates an orphan_device with passed attributes' do
      j = api_post '/onboarding/device', {
        kit_id: 3
      }

      expect(OrphanDevice.where(kit_id: 3).count).to eq(1)
    end
  end

  describe 'PATCH /onboarding/device' do
    it 'updates orphan_device' do

      j = api_put '/onboarding/device', {
        name: 'Owner',
        user_tags: 'cloudy,outdoor',
        description: 'device description'
      }, '0', { 'OnboardingSession' => orphan_device.onboarding_session }

      expect(response.status).to eq(200)
      orphan_device = OrphanDevice.first

      expect(orphan_device.name).to eq('Owner')
      expect(orphan_device.user_tags).to eq('cloudy,outdoor')
      expect(orphan_device.description).to eq('device description')
    end

    it 'requires onboarding_session of existen orphan_device' do
      j = api_put '/onboarding/device', {},'0', {
        'OnboardingSession' => 'invalid onboarding session'
      }

      expect(response.status).to eq(404)
      expect(j['error']).to eq('Invalid OnboardingSession')
    end
  end
end
