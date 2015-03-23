class SCK
  include ActiveModel::Validations

  attr_reader :calibrated_at,
    :bat,
    :co,
    :firmware_param,
    :firmware_version,
    :hardware_version,
    :hum,
    :light,
    :mac,
    :nets,
    :no2,
    :noise,
    :panel,
    :temp,
    :debug_push,
    :smart_cal

  # validates_each :bat, :co, :hum, :light, :nets, :no2, :noise, :panel, :temp do |record, attr, value|
  #   record.errors.add attr, 'must be > 0' if value and value < 0
  #   record.errors.add attr, 'must be numeric' unless ( value.is_a? Fixnum or value.is_a? Float )
  # end
  # validates_presence_of :firmware_param
  # validates_numericality_of :bat, maximum: 1000
  # validates_numericality_of :nets, maximum: 200
  # validates_numericality_of :hum, :light, :noise, :bat, :nets, minimum: 0

  def initialize args = {}
    args.each do |k,v|
      self.send("#{k}=", v) unless v.nil?
    end
    @calibrated_at = Time.now
  end

  def debug_push=(value)

    _raw_data = @hardware_version ? (@firmware_param == "A" ? "1" : "0") : ($smart_cal["raw_data"] ? $smart_cal["raw_data"] : "0")
    _data = {
      device_mac: mac, device_id: device, data: o, device_info: { raw_data: _raw_data, kit_info: (@hardware_version || 'none') }
    }
    begin
      Pusher.trigger('test_channel', 'my_event', _data)
    rescue Pusher::Error => e
      # (Pusher::AuthenticationError, Pusher::HTTPError, or Pusher::Error)
      Rails.logger.info e
    end

  end

  def versions=(value)
    # 1.1-0.8.5-A
    split = value.split('-').map{|a| a.gsub('.','') }
    @firmware_version = split[0].to_i
    @hardware_version = split[1].to_i
    @firmware_param = split[2]
  end

  def temp=(value)
    @temp = [value,restrict_value(value, -300, 500)]
  end

  def hum=(value)
    @hum = [value,restrict_value(value, 0, 1000)]
  end

  def noise=(value, db = nil)
    value = SCK.table_calibration( db, value ) * 100.0
    @noise = [value,restrict_value(value, 0, 16000)]
  end

  def bat=(value)
    @bat = [value,restrict_value(value, 0, 1000)]
  end

  def to_h
    hash = {}
    instance_variables.each {|var| hash[var.to_s.delete("@").to_sym] = instance_variable_get(var) }
    nh = {
      noise: 7,
      light: 14,
      panel: 18,
      co: 16,
      bat: 17,
      hum: 13,
      no2: 15,
      nets: 0,
      temp: 12
    }
    hash.keys.each { |k| hash[nh[k]] = hash[k]; hash.delete(k) }
    Rails.logger.info hash
    return hash
  end

private

  def restrict_value(value, min, max)
    [min, value, max].sort[1]
  end

  def self.table_calibration( arr, raw_value )
    raw_value = raw_value.to_i
    arr = arr.to_a.sort!
    for i in (0..arr.length)
      # Rails.logger.info [raw_value, arr[i], arr[i+1]]
      if raw_value >= arr[i][0] && raw_value < arr[i+1][0]
        low, high = [arr[i], arr[i+1]]
        return SCK.linear_regression(raw_value, low[1], high[1], arr[i][0], high[0])
      end
    end
  end

  def self.linear_regression( valueInput, prevValueOutput, nextValueOutput, prevValueRef, nextValueRef )
    slope = ( nextValueOutput - prevValueOutput ) / ( nextValueRef - prevValueRef )
    result = slope * ( valueInput - prevValueRef ) + prevValueOutput
    return result
  end

  def self.clean_and_cast raw
    begin
      if raw =~ /^\d+$/ or raw.is_a? Integer
        return raw.to_i
      else
        return Float(raw)
      end
    rescue
      return raw
    end
  end

end
