class Device < ActiveRecord::Base

  belongs_to :owner

  belongs_to :owner, class_name: 'User'
  validates_presence_of :owner, :mac_address, :name
  validates_format_of :mac_address, with: /\A([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}\z/
  # validates_uniqueness_of :mac_address

  def readings
    Reading.where(device_id: id)
  end

end
