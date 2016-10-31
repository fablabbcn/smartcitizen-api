require 'rails_helper'

RSpec.describe V0::Onboarding::OrphanDevicesController, type: :controller do
  it { is_expected.to permit(:name, :description, :kit_id, :exposure, :latitude, :longitude,
                             :user_tags).for(:create) }
end
