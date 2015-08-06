class Calibrator

  def initialize mac, raw_data
    device = Device.where(mac_address: mac).last

    if raw_data['version'] # temp fix

      firmware = determine_firmware(raw_data['version'])

      recorded_at = raw_data['timestamp']
      raw_data = raw_data.except('timestamp')

      if (firmware.hardware_version && firmware.hardware_version >= 11) &&
        (firmware.firmware_version && firmware.firmware_version >= 85) &&
        (firmware.firmware_param && firmware.firmware_param =~ /[AB]/)
        # (h.smart_cal && h.smart_cal == 1) &&
        Rails.logger.info("SCK11")
        data = SCK11.new( raw_data )

      elsif (firmware.hardware_version && firmware.hardware_version >= 10) &&
        (firmware.firmware_version && firmware.firmware_version >= 85) &&
        (firmware.firmware_param && firmware.firmware_param =~ /[AB]/)
        Rails.logger.info("SCK1")
        data = SCK1.new( raw_data )

      else
        Rails.logger.info("SCK0")
        data = SCK0.new( raw_data )
        # raise Smartcitizen::UnknownDevice.new h.to_s
      end

      data = data.to_h

      # if recorded_at > device.last_recorded_at
      device.update_attributes(data: data, last_recorded_at: recorded_at)
      # end
      PgReading.create(device: device, data: data, recorded_at: recorded_at)
      Kairos.ingest(device.id, data, recorded_at) # or raw_data?

    end

  end

private

  def determine_firmware version
    o = OpenStruct.new
    split = version.split('-').map{|a| a.gsub('.','') }
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
