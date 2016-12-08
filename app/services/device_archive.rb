require 'fog'
require 'csv'

class DeviceArchive
  attr_reader :device, :s3_file, :headers, :readings_count

  def self.create device_id
    self.new(device_id).s3_file
  end

  def initialize device_id
    @device = Device.find(device_id)
    @headers = []
    @readings_count = 0

    @s3_file = create_s3_file
  end

  def self.s3_connection
    Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['aws_access_key'],
      :aws_secret_access_key    => ENV['aws_secret_key'],
      :region                   => ENV['aws_region'],
    })
  end

  private

  # returns Fog::Storage::AWS::File
  def create_s3_file
    file = DeviceArchive.s3_connection.directories.new(:key => ENV['s3_bucket']).files.new({
      :key    => "devices/#{@device.id}/csv_archive.csv",
      :body   => csv_file.open,
      :public => false,
      :expires => 1.day,
      :content_type => 'text/csv',
      :content_disposition => "attachment; filename=#{@device.id}_#{(Time.now.to_f*1000).to_i}.csv"
    })

    file.save unless Rails.env.test?
    file
  end

  # returns csv tempfile
  #
  # e.g.
  # NO2 in kOhm (MiCS-4514),temp in ºC (HPP828E031),light in KΩ (BH1730FVC),light in dB (POM-3044P-R)
  # 1367301600000,4.0,-52.98927490234375,4.0,57.333333333333336
  # 1364968800000,1.0,-52.997318725585934,1.0,52.5
  # 1366351200000,2.0,-52.994637451171876,2.0,55.0
  # 1366696800000,3.0,-52.99195617675781,3.0,57.0
  # 1367301600000,4.0,-52.98927490234375,4.0,57.333333333333336

  def csv_file
    data_file = generate_data_tempfile

    csv_file = Tempfile.new('csv_file')

    for i in 0..@readings_count do
      line = []
      CSV.foreach(data_file) { |row| line << row[i-1] }

      File.open(csv_file, 'a') do |f|
        f.puts @headers.join(",") if i == 0
        f.puts line.join(",")
      end
    end

    csv_file.close
    data_file.close
    data_file.unlink

    csv_file
  end

  # returns tempfile containing readings data (transposed)

  # e.g.  [line 1: timestamps] 1364968800000,1366351200000,1366696800000,1367301600000
  #       [line 2: sensor1   ] 1.0,2.0,3.0,4.0
  #       [line 3: sensor2   ] -52.997318725585934,-52.994637451171876,-52.99195617675781,-52.98927490234375
  #       [line 4: sensor3   ] 1.0,2.0,3.0,4.0
  #       [line 5: sensor4   ] 52.5,55.0,57.0,57.333333333333336

  def generate_data_tempfile
    tempfile = Tempfile.new('data_tempfile')

    @device.kit.sensor_map.keys.each_with_index do |key, index|
      query = { metrics:[{tags:{device_id:[@device.id]},name: key}], cache_time: 0, start_absolute: 1262304000000 }
      response = Kairos.http_post_to("/datapoints/query",query)
      metric_id = @device.find_sensor_id_by_key(key)

      if component = @device.components.detect{|c| c["sensor_id"] == metric_id}
        values = JSON.parse(response.body)['queries'][0]['results'][0]['values']
        readings = []
        timestamps = [] if index == 0                       # getting timestamps on first iteration
        values.each do |v|
          timestamps << v[0] if index == 0                  # getting timestamps on first iteration
          readings << component.calibrated_value(v[1])
        end
        @readings_count = timestamps.size if index == 0

        File.open(tempfile, 'a') do |f|
          f.puts timestamps.join(",") if index == 0         # writing timestamps on first iteration
          f.puts readings.join(",")
        end
      end
      sensor = Sensor.find(@device.kit.sensor_map[key])
      @headers << "#{sensor.measurement.name} in #{sensor.unit} (#{sensor.name})"
    end

    tempfile
  end
end
