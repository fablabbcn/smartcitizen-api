# == Schema Information
#
# Table name: devices_tags
#
#  id         :integer          not null, primary key
#  device_id  :integer
#  tag_id     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe DevicesTag, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
