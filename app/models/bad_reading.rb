class BadReading < ActiveRecord::Base
  # BAD_PAYLOAD
  # BAD_TIMESTAMP
  # UNREGISTERED_DEVICE
  # BAD_DATA

  def self.add data, header
    create(data: data, remote_ip: header)
  end

end
