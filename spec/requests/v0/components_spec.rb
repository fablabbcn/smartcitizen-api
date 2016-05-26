require 'rails_helper'

describe V0::ComponentsController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }
  let(:admin) { create :admin }
  let(:admin_token) { create :access_token, application: application, resource_owner_id: admin.id }

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
      component = create(:component)
      json = api_get "components/#{component.id}"
      expect(response.status).to eq(200)
    end
  end

end
