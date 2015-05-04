class Calibrator

  def initialize record
    firmware = determine_firmware(record.raw_data['versions'])
    # check_timestamp()

    if (firmware.hardware_version && firmware.hardware_version >= 11) &&
      (firmware.firmware_version && firmware.firmware_version >= 85) &&
      (firmware.firmware_param && firmware.firmware_param =~ /[AB]/)
      # (h.smart_cal && h.smart_cal == 1) &&
      Rails.logger.info("SCK11")
      data = SCK11.new( record.raw_data )

    elsif (firmware.hardware_version && firmware.hardware_version >= 10) &&
      (firmware.firmware_version && firmware.firmware_version >= 85) &&
      (firmware.firmware_param && firmware.firmware_param =~ /[AB]/)
      Rails.logger.info("SCK1")
      data = SCK1.new( record.raw_data )

    else
      Rails.logger.info("ERROR")
      # raise Smartcitizen::UnknownDevice.new h.to_s
    end

    record.update_attributes(data: data.to_h_exc_raw)
    record.device.update_attribute(:data, data.to_h)
  end

private

  def determine_firmware versions
    o = OpenStruct.new
    split = versions.split('-').map{|a| a.gsub('.','') }
    o.firmware_version = split[1].to_i
    o.hardware_version = split[0].to_i
    o.firmware_param = split[2]
    return o
  end

  # def check_timestamp
  #   if ( is_numeric( $timestamp ) )
  #     $timestamp="FROM_UNIXTIME($timestamp)";
  #   else
  #     $timestamp="'$timestamp'"
  # end

end
