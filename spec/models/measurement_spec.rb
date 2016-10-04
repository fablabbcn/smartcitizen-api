# == Schema Information
#
# Table name: measurements
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  unit        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  uuid        :uuid
#

require 'rails_helper'

RSpec.describe Measurement, type: :model do
  it { is_expected.to have_many(:sensors) }

  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:description) }
end
