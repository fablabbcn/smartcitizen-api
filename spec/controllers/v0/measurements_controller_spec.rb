require 'rails_helper'

RSpec.describe V0::MeasurementsController do
  it { is_expected.to permit(:name,:description,:unit).for(:create) }
end
