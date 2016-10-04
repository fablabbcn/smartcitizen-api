# == Schema Information
#
# Table name: tags
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  uuid        :uuid
#

FactoryGirl.define do
  factory :tag do
    sequence(:name) { |n| "tag#{n}"}
    description "tag description"
  end

end
