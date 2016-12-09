require 'fog'

class DeviceArchive
  def self.create device_id
    self.s3_connection.directories.new(:key => ENV['s3_bucket']).files.new({
      :key    => "devices/#{device_id}/csv_archive.csv",
      :body   => self.csv_file(device_id).open,
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

  def self.csv_file device_id
    device = Device.find(device_id)
    return if device.nil?

    data = self.data_hash(device)
    csv_file = Tempfile.new("#{device.id}_csv_temp")

    File.open(csv_file, 'w') do |csv|
      data.each_pair do |key, values|
        csv.puts "#{key},#{values.join(',')}"
      end
    end

    csv_file
  end

  def self.data_hash device
    data = {}
    data['timestamp'] = Array.new(device.kit.sensor_map.keys.length)
    device.kit.sensor_map.keys.each_with_index do |key, index|
      metric_id = device.find_sensor_id_by_key(key)

      return unless component = device.components.detect{ |c| c["sensor_id"] == metric_id }
      values = self.sensor_data(device, key)
      values.each do |v|
        time = Time.at(v[0]/1000).utc
        data[time] ||= Array.new(device.kit.sensor_map.keys.length)
        data[time][index] = component.calibrated_value(v[1])
      end
      sensor = Sensor.find(device.kit.sensor_map[key])
      data['timestamp'][index] = "#{sensor.measurement.name} in #{sensor.unit} (#{sensor.name})"
    end
    data
  end

  def self.sensor_data device, sensor_key
    query = {metrics:[{tags:{device_id:[device.id]},name: sensor_key}],cache_time: 0,start_absolute: 1262304000000}
    response = Kairos.http_post_to("/datapoints/query",query)

    JSON.parse(response.body)['queries'][0]['results'][0]['values']
  end
end
