require 'rails_helper'

describe V0::Onboarding::DeviceRegistrationsController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }
  let(:orphan_device) { create(:orphan_device) }
  let(:onboarding_session) { create(:orphan_device).onboarding_session }

  describe 'POST /onboarding/user' do
    it 'retunrs username if user exists' do
      j = api_post '/onboarding/user', {
        email: user.email,
        onboarding_session: orphan_device.onboarding_session
      }

      expect(j['username']).to eq(user.username)
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

  before do
    create(:kit, id: 1) if Kit.where(id: 1).empty?
    create(:tag, name: 'tag1') if Kit.where(name: 'tag1').empty?
    create(:tag, name: 'tag2') if Kit.where(name: 'tag2').empty?
  end

  describe 'POST /onboarding/register' do
    describe 'creates device from orphan_device and adds it to current_user' do
      before do
        @j = api_post '/onboarding/register', {
          access_token: token.token,
          onboarding_session: orphan_device.onboarding_session
        }
        @device = user.devices.first
      end

      it 'returns created device' do
        expect(response.status).to eq(201)

        expect(@j['name']).to eq(@device.name)
        expect(@j['owner_id']).to eq(user.id)
      end

      it 'attributes added correclty to new device' do
        expect(@device.exposure).to eq(orphan_device.exposure)
        expect(@device.description).to eq(orphan_device.description)
        expect(@device.kit).to eq(Kit.first)
        expect(@device.tags.count).to eq(2)
        expect(@device.location['city']).to eq('Barcelona')
      end
    end

    it 'requires valid onboarding session' do
      j = api_post '/onboarding/register', {
        access_token: token.token,
        onboarding_session: nil
      }

      expect(j['error']).to eq('Invalid onboarding_session')
      expect(response.status).to eq(404)
    end

    it 'requires user authentication' do
      j = api_post '/onboarding/register', {
        onboarding_session: orphan_device.onboarding_session
      }
      expect(j['message']).to eq('Authorization required')
      expect(response.status).to eq(401)
    end
  end
end
