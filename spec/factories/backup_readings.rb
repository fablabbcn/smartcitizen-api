# == Schema Information
#
# Table name: backup_readings
#
#  id         :integer          not null, primary key
#  data       :jsonb
#  mac        :string
#  version    :string
#  ip         :string
#  stored     :boolean
#  created_at :datetime
#

FactoryGirl.define do
  factory :backup_reading do
    data "MyText"
mac "MyString"
version "MyString"
ip "MyString"
created_at "2015-11-18 14:32:27"
  end

end
