class DeviceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :latitude, :longitude, :latest_data
  has_one :owner
  has_one :kit
  has_many :sensors

  def latest_data
    {
      'recorded_at' => Time.zone.now - 1.hour,
      'added_at' => Time.zone.now,
      '1' => '23',
      '2' => '45.39'
    }
  end

end
