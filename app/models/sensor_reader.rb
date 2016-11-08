class SensorReader
  attr_reader :id, :key, :value, :component, :device

  def initialize device, sensor
    @device = device
    begin
      @id = Integer(sensor['id'])
      @key = @device.find_sensor_key_by_id(@id)
    rescue
      @key = sensor['id']
      @id = @device.find_sensor_id_by_key(@key)
    end
    @component = @device.components.detect{ |c| c["sensor_id"] == @id }
    @value = component.normalized_value( (Float(sensor['value']) rescue sensor['value']) )
  end

  def data_hash(ts)
    {
      name: @key,
      timestamp: ts,
      value: @value,
      tags: {
        device_id: @device.id,
        method: 'REST'
      }
    }
  end
end
