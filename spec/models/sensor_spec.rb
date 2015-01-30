require 'rails_helper'

RSpec.describe Sensor, :type => :model do

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:unit) }

  it { is_expected.to have_many(:components) }
  pending { is_expected.to have_many(:boards) }
  pending { is_expected.to have_many(:kits) }

  it "has ancestry"

  pending "has a min and max expectation"

end
