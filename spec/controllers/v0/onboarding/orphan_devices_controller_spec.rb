require 'rails_helper'

RSpec.describe V0::Onboarding::OrphanDevicesController, type: :controller do
  it { is_expected.to permit(:name, :description, :kit_id, :exposure, :latitude, :longitude,
                             :user_tags).for(:create) }

  headers = { 'CONTENT_TYPE' => 'application/json', 'ACCTEPT' => 'application/json' }

  def last_response
    JSON.parse(response.body)
  end

  def create_request(params = {})
    post '/onboarding/device', params.to_json, headers
  end

  describe 'create', type: :request do
    before do
      create_request
    end

    it 'creates an orphan_device without attributes' do
      expect(response.status).to eq(201)
      expect(OrphanDevice.count).to eq(1)
    end

    it 'returns onboarding_session and device_token' do
      expect(OrphanDevice.first.device_token).to eq(last_response['device_token'])
      expect(OrphanDevice.first.onboarding_session).to eq(last_response['onboarding_session'])
    end

    it 'creates an orphan_device with passed attributes' do
      create_request({ kit_id: 3 })

      expect(OrphanDevice.count).to eq(2)
      expect(OrphanDevice.where(kit_id: 3).count).to eq(1)
    end
  end

  describe 'update', type: :request do
    before do
      create_request

      @params = {
         onboarding_session: last_response['onboarding_session'],
         device_token: last_response['device_token'],

         name: 'Owner',
         user_tags: 'cloudy,outdoor',
         description: 'device description'
      }
      patch '/onboarding/device', @params.to_json, headers
    end

    it 'updates orphan_device attributes' do
      expect(response.status).to eq(200)
      expect(OrphanDevice.count).to eq(1)

      orphan_device = OrphanDevice.first

      expect(orphan_device.name).to eq(@params[:name])
      expect(orphan_device.user_tags).to eq(@params[:user_tags])
      expect(orphan_device.description).to eq(@params[:description])
    end

    before do
      def update_request(params = {})
        patch '/onboarding/device', params.to_json, headers
      end
    end

    it 'requires onboarding_session' do
      update_request()

      expect(response.status).to eq(422)
      expect(last_response['error']).to eq('Missing Params')
    end

    it 'requires device_token' do
      update_request({ onboarding_session: SecureRandom.uuid })

      expect(response.status).to eq(422)
      expect(last_response['error']).to eq('Missing Params')
    end

    it 'requires device_token of existen orphan_device' do
      update_request({ onboarding_session: SecureRandom.uuid, device_token: '1111111' })

      expect(response.status).to eq(404)
      expect(last_response['error']).to eq('Invalid device_token')
    end
  end
end
