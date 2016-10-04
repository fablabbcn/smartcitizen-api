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

FactoryGirl.define do
  factory :kit do
    name "Testing kit"
    description "A kit that was made for the test environment"
  end

end
