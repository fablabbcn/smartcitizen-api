require 'time'

data = {}
data["1.0"] = {
  noise: 7,
  light: 6,
  panel: 11,
  co: 9,
  bat: 10,
  hum: 5,
  no2: 8,
  nets: 21,
  temp: 4
}
data["1.1"] = {
  noise: 7,
  light: 14,
  panel: 18,
  co: 16,
  bat: 17,
  hum: 13,
  no2: 15,
  nets: 21,
  temp: 12
}

namespace :i do
  task :times => :environment do
    Dir['/home/deployer/apps/smartcitizen_production/current/tailimports/*.txt'].each do |txt_file|
      begin
        device_id = nil
        File.open(txt_file, 'r') do |file|
          a = []
          if lines = file.each_line.each_slice(9).to_a.last and lines.length == 9
            h = {}
            a << h
            lines.each do |line|
              match = line.match(/put (\w+) (\d+) ([\d.-]+) device_id=(\d+) identifier=sck([\d.]+)/)
              time = Time.at(match[2].to_i/1000).iso8601
              value = match[3].to_f
              device_id = match[4].to_i
              sck = match[5]
              sensor = data[sck][match[1].to_sym].to_s
              h[""] = time

              device = Device.find(device_id)
              sensor_id = device.find_sensor_id_by_key(match[1])
              component = device.find_component_by_sensor_id(sensor_id)

              h[sensor] = component.calibrated_value(value)
              h["#{sensor}_raw"] = value
            end
            # puts sensor, time, value, device_id, sck
          else
            next
          end
          if device.last_reading_at < 8.hours_ago
            device.update_column(:data, a[0])
          end
        end
      rescue
        puts "ERROR #{device_id}"
      end
    end
  end
end
