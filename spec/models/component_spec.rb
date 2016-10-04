# == Schema Information
#
# Table name: components
#
#  id               :integer          not null, primary key
#  board_id         :integer
#  board_type       :string
#  sensor_id        :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  uuid             :uuid
#  equation         :text
#  reverse_equation :text
#

require 'rails_helper'

RSpec.describe Component, :type => :model do
  it { is_expected.to belong_to(:board) }
  it { is_expected.to belong_to(:sensor) }
  it { is_expected.to validate_presence_of(:board) }
  it { is_expected.to validate_presence_of(:sensor) }

  it "validates uniqueness of board to sensor" do
    component = create(:component, board: create(:kit), sensor: create(:sensor))
    expect{ create(:component, board: component.board, sensor: component.sensor) }.to raise_error(ActiveRecord::RecordInvalid)
  end

end
