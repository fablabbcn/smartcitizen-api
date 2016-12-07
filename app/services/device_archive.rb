require 'fog'

class DeviceArchive
  def self.new_file device_id
    s3 = self.s3_connection
    key = "devices/#{device_id}/csv_archive.csv"

    s3.directories.new(:key => ENV['s3_bucket']).files.new({
      :key    => key,
      :body   => self.generate_csv(device_id),
      :public => false,
      :expires => 1.day,
      :content_type => 'text/csv',
      :content_disposition => "attachment; filename=#{device_id}_#{(Time.now.to_f*1000).to_i}.csv"
    })
  end

  def self.s3_connection
    Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['aws_access_key'],
      :aws_secret_access_key    => ENV['aws_secret_key'],
      :region                   => ENV['aws_region'],
    })
  end

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
      sensor_headings << "#{sensor.measurement.name} in #{sensor.unit} (#{sensor.name})"
    end

    csv = "timestamp,#{sensor_headings.join(',')}\n"
    csv += data.map{|d| d.join(",")}.join("\n")
  end

end
