class Reading
  include Cequel::Record

  key :id, :timeuuid, auto: true
  column :device_id, :int, index: true
  column :value, :text

  def device
    Device.find(device_id)
  end

end
