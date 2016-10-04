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

FactoryGirl.define do
  factory :component do
    uuid { SecureRandom.uuid }
    association :board, factory: :kit
    association :sensor
  end

end
