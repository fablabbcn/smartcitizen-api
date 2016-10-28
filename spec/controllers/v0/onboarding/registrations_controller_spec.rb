require 'rails_helper'

RSpec.describe V0::Onboarding::RegistrationsController, type: :controller do
  # it { is_expected.to permit(:email, :onboarding_session, :device_token).for(:find_user) }

  def last_response
    JSON.parse(response.body)
  end

  describe 'find_user', type: :request do
    before do
      @user = create(:user)
      @orphan_device = create(:orphan_device)

      def find_user_request(email, device_token)
        headers = { 'CONTENT_TYPE' => 'application/json', 'ACCTEPT' => 'application/json' }

        params = {
          email: email,
          device_token: device_token,
          onboarding_session: @orphan_device.onboarding_session
        }

        post '/onboarding/user', params.to_json, headers
      end
    end

    it 'finds returns username if user exist' do
      find_user_request(@user.email, @orphan_device.device_token)

      expect(last_response['username']).to eq(@user.username)
      expect(response.status).to eq(200)
    end

    it 'requires email' do
      find_user_request(nil, @orphan_device.device_token)

      expect(last_response['error']).to eq('Missing Params')
      expect(response.status).to eq(422)
    end

    it 'returns not_found if user does not exist' do
      find_user_request('new_user@email', @orphan_device.device_token)

      expect(last_response['message']).to eq('not_found')
      expect(response.status).to eq(404)
    end

    it 'requires valid device_token' do
      find_user_request('new_user@email', '1111111')

      expect(last_response['error']).to eq('Invalid device_token')
      expect(response.status).to eq(404)
    end
  end
end
