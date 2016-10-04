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

# This class is due to be removed, similar to BackupReading it's used to
# store readings that are posted. Specifically readings that are not valid.

class BadReading < ActiveRecord::Base
  # BAD_PAYLOAD
  # BAD_TIMESTAMP
  # UNREGISTERED_DEVICE
  # BAD_DATA

  def self.add data, header, message = nil
    create(data: data, remote_ip: header, message: message)
  end

end
