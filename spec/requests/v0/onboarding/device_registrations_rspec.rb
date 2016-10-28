require 'rails_helper'

describe V0::Onboarding::DeviceRegistrationsController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }
  let(:device) { create(:device) }
  let(:orphan_device) { create(:orphan_device) }
  let(:onboarding_session) { create(:orphan_device).onboarding_session }

  # let(:admin) { create :admin }
  # let(:admin_token) { create :access_token, application: application, resource_owner_id: admin.id }

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
end

  # describe "POST /devices" do
  #
  #   it "creates a device" do
  #     api_post 'devices', {
  #       access_token: token.token,
  #       name: 'my device',
  #       description: 'for checking stuff',
  #       mac_address: 'BD-B1-DE-13-67-31',
  #       latitude: 41.3966908,
  #       longitude: 2.1921909
  #     }
  #     expect(response.status).to eq(201)
  #   end
  #
  #   it "does not create a device with missing parameters" do
  #     api_post 'devices', {
  #       name: nil,
  #       access_token: token.token
  #     }
  #     expect(response.status).to eq(422)
  #   end
  #
  #   it "does not create a device with invalid access_token" do
  #     api_post "devices", { device: { name: 'test' }, access_token: '123' }
  #     expect(response.status).to eq(401)
  #   end
  #
  #   it "does not create a device with missing access_token" do
  #     api_post "devices", { device: { name: 'test' }, access_token: nil }
  #     expect(response.status).to eq(401)
  #   end
  #
  #   # it "does not create a device with empty parameters access_token" do
  #   #   api_post "devices", { device: { name: nil }, access_token: token.token }
  #   #   expect(response.status).to eq(422)
  #   # end
  # end
  #
  # describe "DELETE /devices/:id" do
  #
  #   let!(:device) { create :device, owner: user }
  #
  #   it "deletes a device" do
  #     api_delete "devices/#{device.id}", { access_token: token.token }
  #     expect(response.status).to eq(200)
  #   end
  #
  #   it "does not delete a device with invalid access_token" do
  #     api_delete "devices/#{device.id}", { access_token: '123' }
  #     expect(response.status).to eq(403)
  #   end
  #
  #   it "does not delete a device with missing access_token" do
  #     api_delete "devices/#{device.id}"
  #     expect(response.status).to eq(403)
  #   end
  #
  # end
  #
  # describe "states" do
  #
  #   before(:all) do
  #     @not_configured = create(:device, mac_address: nil)
  #     @never_published = create(:device, mac_address: '2a:f3:e6:d9:76:84')
  #     @has_published = create(:device, mac_address: '2a:f3:e6:d9:76:86', data: {'a': 'b'})
  #   end
  #
  #   after(:all) do
  #     DatabaseCleaner.clean_with(:truncation)
  #   end
  #
  #   %w(not_configured never_published has_published).each do |state|
  #     it "filters by q[state_eq] #{state}" do
  #       json = api_get "devices?q[state_eq]=#{state}"
  #       expect(response.status).to eq(200)
  #       expect(json.map{|j| j['id']}).to eq([ instance_variable_get("@#{state}") ].map(&:id))
  #     end
  #   end
  #
  # end
# end
