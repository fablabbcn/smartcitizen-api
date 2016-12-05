class DeviceArchive

  def self.generate_csv device_id
    device = Device.find(device_id)

    data = {}
    sensor_headings = []
    device.kit.sensor_map.keys.each_with_index do |key, index|
      query = { metrics:[{tags:{device_id:[device_id]},name: key}], cache_time: 0, start_absolute: 1262304000000 }
      response = Kairos.http_post_to("/datapoints/query",query)
      metric_id = device.find_sensor_id_by_key(key)
      if component = device.components.detect{|c| c["sensor_id"] == metric_id}
        values = JSON.parse(response.body)['queries'][0]['results'][0]['values']
        values.each do |v|
          time = Time.at(v[0]/1000).utc
          data[time] ||= Array.new(device.kit.sensor_map.keys.length)
          data[time][index] = component.calibrated_value(v[1])
        end
      end
      sensor = Sensor.find(device.kit.sensor_map[key])
      sensor_headers << "#{sensor.measurement.name} in #{sensor.unit} (#{sensor.name})"
    end

    csv = "timestamp,#{sensor_headings.join(',')}\n"
    csv += data.map{|d| d.join(",")}.join("\n")
  end

end
