require 'rails_helper'

describe V0::Onboarding::DeviceRegistrationsController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }
  let(:orphan_device) { create(:orphan_device, name: 'EasyToFind') }
  let(:onboarding_session) { create(:orphan_device).onboarding_session }

  describe 'POST /onboarding/user' do
    before do
      @user = create(:user)
      @onboarding_session = create(:orphan_device).onboarding_session
    end

    it 'retunrs username if user exists' do
      j = api_post '/onboarding/user', {
        email: @user.email,
        onboarding_session: @onboarding_session
      }

      expect(j['username']).to eq(@user.username)
      expect(response.status).to eq(200)
    end

    it 'requires email' do
      j = api_post '/onboarding/user', {
        onboarding_session: onboarding_session
      }

      expect(j['error']).to eq('Missing Params')
      expect(response.status).to eq(422)
    end

    it 'returns not_found if user does not exist' do
      j = api_post '/onboarding/user', {
        email: 'new_user@email',
        onboarding_session: onboarding_session
      }

      expect(j['message']).to eq('not_found')
      expect(response.status).to eq(404)
    end

    it 'requires valid onboarding_session' do
      j = api_post '/onboarding/user', {
        email: 'new_user@email',
        onboarding_session: '111111'
      }

      expect(j['error']).to eq('Invalid onboarding_session')
      expect(response.status).to eq(404)
    end
  end

  describe 'POST /onboarding/user' do
    it 'creates device from orphan_device and adds it to current_user' do
      j = api_post '/onboarding/register', {
        access_token: token.token,
        onboarding_session: orphan_device.onboarding_session
      }
      device = user.devices.first

      expect(Device.count).to eq(1)
      expect(response.status).to eq(201)
      expect(device.name).to eq(orphan_device.name)
      expect(j['name']).to eq(device.name)
      expect(j['owner_id']).to eq(user.id)
    end
  end
end
