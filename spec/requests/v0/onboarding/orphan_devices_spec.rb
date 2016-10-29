require 'rails_helper'

describe V0::Onboarding::OrphanDevicesController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }
  let(:device) { create(:device) }
  let(:orphan_device) { create(:orphan_device) }

  describe 'POST /onboarding/device' do
    it 'returns onboarding_session and device_token of created orphan_device' do
      j = api_post '/onboarding/device', {}

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
    before do
      @orphan_device = create(:orphan_device)
    end

    it 'updates orphan_device with passed onboarding_session' do

      j = api_put '/onboarding/device', {
        onboarding_session: @orphan_device.onboarding_session,

        name: 'Owner',
        user_tags: 'cloudy,outdoor',
        description: 'device description'
      }

      expect(response.status).to eq(200)
      orphan_device = OrphanDevice.first

      expect(orphan_device.name).to eq('Owner')
      expect(orphan_device.user_tags).to eq('cloudy,outdoor')
      expect(orphan_device.description).to eq('device description')
    end

    it 'requires onboarding_session' do
      j = api_put '/onboarding/device', {}

      expect(response.status).to eq(422)
      expect(j['error']).to eq('Missing Params')
    end

    it 'requires onboarding_session of existen orphan_device' do
      j = api_put '/onboarding/device', { onboarding_session: '1111111' }

      expect(response.status).to eq(404)
      expect(j['error']).to eq('Invalid onboarding_session')
    end
  end
end
