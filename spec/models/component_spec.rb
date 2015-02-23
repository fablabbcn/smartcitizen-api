require 'rails_helper'

RSpec.describe Component, :type => :model do
  it { is_expected.to belong_to(:board) }
  it { is_expected.to belong_to(:sensor) }
  it { is_expected.to validate_presence_of(:board) }
  it { is_expected.to validate_presence_of(:sensor) }

  it "validates uniqueness of board to sensor" do
    component = create(:component, board: create(:kit), sensor: create(:sensor))
    expect{ create(:component, board: component.board, sensor: component.sensor) }.to raise_error
  end

end
