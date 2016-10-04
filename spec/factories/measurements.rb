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

FactoryGirl.define do
  factory :measurement do
    sequence(:name) { |i| "Temperature #{i}" }
    description "How hot something is"
    unit "C"
  end
end
