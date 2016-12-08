require 'fog'

### Usage ###
#
# file = DeviceArchive.new(device_id) #=> (Fog::Storage::AWS::File Class)
# file.body #=> "timestamp,NO2 in kOhm (MiCS-4514),temp in ºC (HPP828E031)\n"
#               "2013-04-03 06:00:00 UTC,1.0,-52.997318725585934\n"
#               "2013-04-19 06:00:00 UTC,2.0,-52.994637451171876"
# file.save #=> true (pushes to amazon s3)
# file.url(24.hours.from_now) #=> "https://test.s3-test.amazonaws.com/devices/1/csv_archive.csv?X-Amz-Expires=86400&X-Amz-Date=20161208T075206Z&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=test/20161208/test/s3/aws4_request&X-Amz-SignedHeaders=host&X-Amz-Signature=052b183ff4bc77fce9bcb9277ea8669172712cd9ac7978d073ac111ac9ab8c8e"

class DeviceArchive
  attr_reader :device, :sensor_headings, :s3_file

  def initialize device_id
    @device = Device.find(device_id)
    @sensor_headings = []

    @s3_file = new_s3_file(csv_tempfile)
  end

  def body
    s3_file.open
    body = s3_file.body
    s3_file.close
    body
  end

  private

  def csv_tempfile
    generate_csv_file(get_data)
  end

  def get_data
    data = {}

    @device.kit.sensor_map.keys.each_with_index do |key, index|
      query = { metrics:[{tags:{device_id:[@device.id]},name: key}], cache_time: 0, start_absolute: 1262304000000 }
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
      @sensor_headings << "#{sensor.measurement.name} in #{sensor.unit} (#{sensor.name})"
    end

    data
  end

  def generate_csv_file(data_hash)
    tempfile = Tempfile.new("#{@device.id}_archive.csv") # create temp file
    tempfile << "timestamp,#{@sensor_headings.join(',')}\n"      # write csv headings

    data_hash.each do |timestamp, readings|                  # write data
      tempfile.open
      tempfile << "#{timestamp},#{readings.join(",")}\n"
      tempfile.close
    end

    tempfile                                             # return file
  end

  def new_s3_file(tempfile)
    file = s3_connection.directories.new(:key => ENV['s3_bucket']).files.new({
      :key    => "devices/#{@device.id}/csv_archive.csv",
      :body   => tempfile.open,
      :public => false,
      :expires => 1.day,
      :content_type => 'text/csv',
      :content_disposition => "attachment; filename=#{@device.id}_#{(Time.now.to_f*1000).to_i}.csv"
    })

    tempfile.close                    # close & delete tempfile
    tempfile.unlink

    puts file.body

    file.save unless Rails.env.test?  # MOCK fog on spec and remove condition! (DeviceArchive won't be executed if test)
    file                              # return Fog::Storage::AWS::File
  end

  def s3_connection
    Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['aws_access_key'],
      :aws_secret_access_key    => ENV['aws_secret_key'],
      :region                   => ENV['aws_region'],
    })
  end
end
