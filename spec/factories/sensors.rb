# == Schema Information
#
# Table name: sensors
#
#  id             :integer          not null, primary key
#  ancestry       :string
#  name           :string
#  description    :text
#  unit           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  measurement_id :integer
#  uuid           :uuid
#

FactoryGirl.define do
  factory :sensor do
    name "MiCS-2710"
    description "Metaloxide gas sensor"
    unit "KΩ"
  end
end
