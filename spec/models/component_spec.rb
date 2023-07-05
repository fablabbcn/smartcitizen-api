require 'rails_helper'

RSpec.describe Component, :type => :model do
  it { is_expected.to belong_to(:device) }
  it { is_expected.to belong_to(:sensor) }
  it { is_expected.to validate_presence_of(:device) }
  it { is_expected.to validate_presence_of(:sensor) }

  it "validates uniqueness of board to sensor" do
    component = create(:component, device: create(:device), sensor: create(:sensor))
    expect{ create(:component, device: component.device, sensor: component.sensor) }.to raise_error(ActiveRecord::RecordInvalid)
  end

end
