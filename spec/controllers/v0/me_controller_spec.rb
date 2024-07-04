require 'rails_helper'

RSpec.describe V0::MeController do
  skip { is_expected.to permit(:email,:username,:password,:city,:country_code,:url).for(:update) }
end
