require 'rails_helper'

RSpec.describe Component, :type => :model do
  it { is_expected.to belong_to(:board) }
  it { is_expected.to belong_to(:sensor) }
  it { is_expected.to validate_presence_of(:board) }
  it { is_expected.to validate_presence_of(:sensor) }
  skip { is_expected.to validate_uniqueness_of(:board_id).scoped_to(:sensor_id) }
end