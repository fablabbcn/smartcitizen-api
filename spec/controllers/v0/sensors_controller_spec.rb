require 'rails_helper'

RSpec.describe V0::SensorsController do
  it { is_expected.to permit(:name,:description,:unit,:measurement_id).for(:create) }
end
