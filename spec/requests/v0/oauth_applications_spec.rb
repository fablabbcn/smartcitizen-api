require 'rails_helper'

describe V0::OauthApplicationsController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }
  let(:admin) { create :admin }
  let(:admin_token) { create :access_token, application: application, resource_owner_id: admin.id }

  it "needs specs"

end
