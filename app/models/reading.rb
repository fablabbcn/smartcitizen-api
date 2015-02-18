# CREATE TABLE readings (
#   device_id int,
#   recorded_month int,
#   recorded_at timestamp,
#   raw_values map<text, text>,
#   values map<text, text>,
#   PRIMARY KEY ((device_id, recorded_month), recorded_at)
# ) WITH CLUSTERING ORDER BY (recorded_at DESC);

class Reading

  def device
    Device.find(device_id)
  end

  def self.add device_id, recorded_at, values
    values = values.sort.to_h.to_json.gsub(/\"/,"'")
    $cassandra.execute("INSERT INTO readings(device_id, recorded_month, recorded_at, values)
      VALUES (#{device_id}, #{recorded_at.strftime('%Y%m')}, '#{recorded_at.iso8601}', #{values})")
  end

  def self.for_device_id device_id
    months = [2015,2014].collect{|y| ("#{y}01".to_i.."#{y}12".to_i).to_a.reverse }.join(',')
    $cassandra.execute("SELECT recorded_at, values FROM readings
      WHERE device_id = #{device_id} AND recorded_month IN (#{months})")
  end

  def self.first
    OpenStruct.new($cassandra.execute("SELECT * FROM readings LIMIT 1").first)
  end

end
