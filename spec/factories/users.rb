# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  username             :string
#  email                :string
#  password_digest      :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  password_reset_token :string
#  city                 :string
#  country_code         :string
#  url                  :string
#  avatar_url           :string
#  role_mask            :integer          default(0), not null
#  uuid                 :uuid
#  legacy_api_key       :string           not null
#  old_data             :jsonb
#  cached_device_ids    :integer          is an Array
#  workflow_state       :string
#

FactoryGirl.define do

  factory :user do
    uuid { SecureRandom.uuid }
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@bitsushi.com" }
    password "password1"
    url "http://www.yahoo.com"

    factory :admin do
      role_mask 5
    end
  end

end
