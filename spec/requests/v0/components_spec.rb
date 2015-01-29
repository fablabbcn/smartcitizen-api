require 'rails_helper'

describe V0::ComponentsController do

  it "needs tests to check you are admin"

  describe "GET /" do
    it "returns a list of components" do
      api_get 'components'
      expect(response.status).to eq(200)
    end
  end

end
