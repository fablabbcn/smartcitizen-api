# == Schema Information
#
# Table name: bad_readings
#
#  id          :integer          not null, primary key
#  tags        :integer
#  remote_ip   :string
#  data        :jsonb            not null
#  created_at  :datetime         not null
#  message     :string
#  device_id   :integer
#  mac_address :string
#  version     :string
#  timestamp   :string
#  backtrace   :text
#

require 'rails_helper'

RSpec.describe BadReading, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
