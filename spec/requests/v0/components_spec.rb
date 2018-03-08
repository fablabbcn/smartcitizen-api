require 'rails_helper'

describe V0::ComponentsController do

  # We were SOMETIMES getting 6 records instead of 2 in GET /components
  before do
    DatabaseCleaner.clean_with(:truncation)
  end

  let(:application) { build :application }
  let(:user) { build :user }
  let(:token) { build :access_token, application: application, resource_owner_id: user.id }
  let(:admin) { build :admin }
  let(:admin_token) { build :access_token, application: application, resource_owner_id: admin.id }
  let(:component3) { build :component }

  describe "GET /components" do

    it "returns a list of components" do
      component1 = create(:component)
      component2 = create(:component)

      json = api_get 'components'

      expect(response.status).to eq(200)
      expect(json.length).to eq(2)
      expect(json[0]['uuid']).to eq(component1.uuid)
      expect(json[0].keys).to eq(
        %w(id uuid board_id board_type sensor_id created_at updated_at)
      )
    end
  end

  describe "GET /components/<id>" do
    it "returns a component" do
      json = api_get "components/#{component3.id}"
      expect(response.status).to eq(200)
    end
  end

end
