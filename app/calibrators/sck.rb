class SCK
  # Validators
  # recorded_at: required and > 1.year.ago and < 1.day.ahead
  # mac: /\A([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}\z/
  # return false unless mac =~ /\A([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}\z/

  attr_reader :temp, :hum, :noise, :bat, :firmware_version, :hardware_version, :firmware_param, :calibrated_at

  def initialize args = {}
    args.each do |k,v|
      self.send("#{k}=", v) unless v.nil?
    end
    @calibrated_at = Time.now
  end

  def versions=(value)
    # 1.1-0.8.5-A
    split = value.split('-').map{|a| a.gsub('.','') }
    @firmware_version = split[0].to_i
    @hardware_version = split[1].to_i
    @firmware_param = split[2]
  end

  def temp=(value)
    @temp = value.to_f.restrict_to(-300, 500)
  end

  def hum=(value)
    @hum = value.to_f.restrict_to(0, 1000)
  end

  def noise=(value)
    db = {5 => 45,10 => 55,15 => 63,20 => 65,30 => 67,40 => 69,50 => 70,60 => 71,80 => 72,90 => 73,100 => 74,130 => 75,160 => 76,190 => 77,220 => 78,260 => 79,300 => 80,350 => 81,410 => 82,450 => 83,550 => 84,600 => 85,650 => 86,750 => 87,850 => 88,950 => 89,1100 => 90,1250 => 91,1375 => 92,1500 => 93,1650 => 94,1800 => 95,1900 => 96,2000 => 97,2125 => 98,2250 => 99,2300 => 100,2400 => 101,2525 => 102,2650 => 103}
    value = SCK.table_calibration( db, value ) * 100.0
    @noise = value.to_f.restrict_to(0, 16000)
  end

  def bat=(value)
    @bat = value.to_f.restrict_to(0, 1000)
  end

  def to_h
    hash = {}
    instance_variables.each {|var| hash[var.to_s.delete("@").to_sym] = instance_variable_get(var) }
    return hash
  end

private

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
