require 'rails_helper'

describe V0::ComponentsController do

  describe "GET /" do

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

end
