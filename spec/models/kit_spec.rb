# == Schema Information
#
# Table name: kits
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  slug        :string
#  uuid        :uuid
#  sensor_map  :jsonb
#

require 'rails_helper'

RSpec.describe Kit, :type => :model do
  it { is_expected.to have_many(:devices) }
  it { is_expected.to have_many(:components) }
  it { is_expected.to have_many(:sensors) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:description) }
end
