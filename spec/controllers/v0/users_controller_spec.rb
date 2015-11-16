require 'rails_helper'

RSpec.describe V0::UsersController do
  it { is_expected.to permit(:email,:username,:password,:city,:country_code,:url,:avatar,:avatar_url).for(:create) }
end
