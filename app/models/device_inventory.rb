class DeviceInventory < ActiveRecord::Base

  self.table_name = 'devices_inventory'

  def report
    self[:report]
  end

  def report=(str)
    self[:report] = JSON.parse(str) rescue nil
  end

end
