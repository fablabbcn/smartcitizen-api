require 'rails_helper'

RSpec.describe V0::Onboarding::DeviceRegistrationsController, type: :controller do
  it { is_expected.to permit(:email).for(:find_user, verb: :post) }
end
