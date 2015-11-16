require 'rails_helper'

RSpec.describe V0::MeController do
  skip { is_expected.to permit(:email,:username,:password,:city,:country_code,:url,:avatar,:avatar_url).for(:update) }
end
