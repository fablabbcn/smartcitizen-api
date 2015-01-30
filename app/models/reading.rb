class Reading

  include Cequel::Record

  # device_id:recorded_at:created_at

  before_create :update_device

  key :id, :timeuuid, auto: true
  map :values, :text, :text
  column :device_id, :int, index: true
  column :recorded_at, :timestamp

  validates_presence_of :device_id, :values

  def device
    @device ||= Device.find(device_id)
  end

  def device=(device)
    self.device_id = device.id
  end

private

  def update_device
    device.latest_data = values.to_hash
    device.save!
  end

end
