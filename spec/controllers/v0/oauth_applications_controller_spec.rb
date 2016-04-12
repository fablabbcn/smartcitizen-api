require 'rails_helper'

RSpec.describe V0::OauthApplicationsController do
  skip { is_expected.to permit(:name,:description,:unit).for(:create) }
end
