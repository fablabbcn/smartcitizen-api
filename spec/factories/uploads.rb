# == Schema Information
#
# Table name: uploads
#
#  id                :integer          not null, primary key
#  type              :string
#  original_filename :string
#  metadata          :jsonb
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  uuid              :uuid
#  user_id           :integer
#  key               :string
#

FactoryGirl.define do

  factory :upload do
    type "Avatar"
    association :user
    original_filename "testing.jpg"
  end

end
