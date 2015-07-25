require 'rails_helper'

describe V0::ComponentsController do

  it "needs tests to check you are admin"

  describe "GET /" do
    it "returns a list of components" do
      create(:component)
      create(:component)
      json = api_get 'components'
      expect(response.status).to eq(200)
      expect(json.length).to eq(2)
    end
  end

end
