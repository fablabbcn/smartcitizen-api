module Mathematician

  # s = <<-CODE
  #   noise = {5 => 45,10 => 55,15 => 63,20 => 65,30 => 67,40 => 69,50 => 70,60 => 71,80 => 72,90 => 73,100 => 74,130 => 75,160 => 76,190 => 77,220 => 78,260 => 79,300 => 80,350 => 81,410 => 82,450 => 83,550 => 84,600 => 85,650 => 86,750 => 87,850 => 88,950 => 89,1100 => 90,1250 => 91,1375 => 92,1500 => 93,1650 => 94,1800 => 95,1900 => 96,2000 => 97,2125 => 98,2250 => 99,2300 => 100,2400 => 101,2525 => 102,2650 => 103}
  #   Mathematician.table_calibration(noise, x)
  # CODE

  def self.reverse_table_calibration( arr, raw_value )
    raw_value = raw_value.to_f
    arr = Hash[arr.collect{|k,v| [v,k] }].to_a.sort!

    if (raw_value >= arr.last[0])
      return arr.last[1].to_f
    end

    clamped_value = [arr.first[0], raw_value, arr.last[0]-1].sort[1]

    for i in (0..arr.length-1)
      if clamped_value >= arr[i][0] && clamped_value < arr[i+1][0]
        low, high = [arr[i], arr[i+1]]
        return self.linear_regression(clamped_value,low[1],high[1],arr[i][0],high[0])
      end
    end
  end

  def self.table_calibration( arr, raw_value )
    raw_value = raw_value.to_f
    arr = arr.to_a.sort!

    if (raw_value >= arr.last[0])
      return arr.last[1].to_f
    end

    # new_value = [raw_value, [raw_value, arr.last[0]-1].min, arr.first[0]].max
    clamped_value = [arr.first[0], raw_value, arr.last[0]-1].sort[1]

    # Rails.logger.info("arr=#{arr.join(',')}".yellow)
    # Rails.logger.info("raw_value=#{raw_value}".yellow)
    # Rails.logger.info("clamped_value=#{clamped_value}".yellow)

    for i in (0..arr.length-1)
      if clamped_value >= arr[i][0] && clamped_value < arr[i+1][0]
        low, high = [arr[i], arr[i+1]]
        return self.linear_regression(clamped_value,low[1],high[1],arr[i][0],high[0])
      end
    end
  end

  def self.linear_regression( valueInput, prevValueOutput, nextValueOutput, prevValueRef, nextValueRef )
    slope = ( nextValueOutput.to_f - prevValueOutput.to_f ) / ( nextValueRef.to_f - prevValueRef.to_f )
    result = slope.to_f * ( valueInput.to_f - prevValueRef.to_f ) + prevValueOutput.to_f
    return result
  end

end
