require 'rails_helper'

RSpec.describe Sensor, :type => :model do

  it { is_expected.to belong_to(:measurement) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:description) }
  # it { is_expected.to validate_presence_of(:unit) }

  it { is_expected.to have_many(:components) }
  # it { is_expected.to have_many(:boards).through(:components) }
  # it { is_expected.to have_many(:kits).through(:components) }

  it "has ancestry"

  pending "has a min and max expectation"

end
