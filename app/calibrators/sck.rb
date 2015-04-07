class SCK

  # include ActiveModel::Validations
  # validates_each :bat, :co, :hum, :light, :nets, :no2, :noise, :panel, :temp do |record, attr, value|
  #   record.errors.add attr, 'must be > 0' if value and value < 0
  #   record.errors.add attr, 'must be numeric' unless ( value.is_a? Fixnum or value.is_a? Float )
  # end
  # validates_presence_of :firmware_param
  # validates_numericality_of :bat, maximum: 1000
  # validates_numericality_of :nets, maximum: 200
  # validates_numericality_of :hum, :light, :noise, :bat, :nets, minimum: 0

  attr_accessor :calibrated_at,
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
    :smart_cal,
    :timestamp,
    :ip

  def initialize args = {}
    args.each do |k,v|
      self.send("#{k}=", to_f_or_i_or_s(v)) unless v.nil?
    end
    @calibrated_at = Time.current.utc
  end

  def versions=(value)
    # 1.1-0.8.5-A
    split = value.split('-')#.map{|a| a.gsub('.','') }
    @firmware_version = split[1]
    @hardware_version = split[0]
    @firmware_param = split[2]
  end

  def temp=(value, calib = nil)
    @temp = [value,restrict_value(calib || value, -300, 500)]
    # @temp = restrict_value(calib || value, -300, 500)
  end

  def hum=(value, calib = nil)
    @hum = [value,restrict_value(calib || value, 0, 1000)]
    # @hum = restrict_value(calib || value, 0, 1000)
  end

  def noise=(value, db = nil)
    raise "call from a subclass" unless db
    new_value = SCK.table_calibration( db, value ) * 100
    @noise = [value,new_value].uniq
    # @noise = new_value
  end

  def bat=(value)
    @bat = [value,restrict_value(value, 0, 1000)]
    # @bat = restrict_value(value, 0, 1000)
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
    hash.keys.each do |k|
      if hash[k].is_a?(Array)
        hash[nh[k]] = hash[k].last
        hash["#{nh[k]}_raw"] = hash[k].first
      else
        hash[nh[k]] = hash[k]
      end
      hash.delete(k)
    end
    return hash
  end

private

  def to_f_or_i_or_s(v)
    ((float = Float(v)) && (float % 1.0 == 0) ? float.to_i : float) rescue v
  end

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

end
