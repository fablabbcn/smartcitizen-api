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



  def self.compose mac, version, data
    return false unless mac =~ /\A([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}\z/

    o = OpenStruct.new(mac: mac, data: data)
    o.firmware_version, o.hardware_version, o.firmware_param = version.split('-').map{|a| a.gsub('.','') }

    # if ($debug_push == 1) {
    #   $deviceinfo["raw_data"] = (isset($kit_version) && $kit_version) ? (($kit_firmware_param_1 == "A") ? "1" : "0") : ((isset($smart_cal["raw_data"])) ? $smart_cal["raw_data"] : "0");
    #   $deviceinfo["kit_info"] = (isset($kit_version) && $kit_version) ? $kit_version : "none";
    #   $pushData=array("device_mac" => $macaddr, "device_id" => $deviceid, "device_info" => $deviceinfo, "data" => $data);
    #   $pusher = new Pusher('2f8a2d729234d3433657', '3c1ca2887cdc39d440c2', '61006');
    #   $pusher->trigger('test_channel', 'my_event', $pushData);
    # }

    if o.data.smart_cal == 1 && o.hardware_version >= 11 && o.firmware_version >= 85 && o.firmware_param =~ /[AB]/
      # currently CO and NO2 calibration is disabled for all devices.
      # this calibration should happen on the display side on the platform, api and iphone api.

      # $dbTable = json_decode( file_get_contents( "sensors/db.json" ), true );
      db = {0=>50,2=>55,3=>57,6=>58,20=>59,40=>60,60=>61,75=>62,115=>63,150=>64,180=>65,220=>66,260=>67,300=>68,375=>69,430=>70,500=>71,575=>72,660=>73,720=>74,820=>75,900=>76,975=>77,1050=>78,1125=>79,1200=>80,1275=>81,1320=>82,1375=>83,1400=>84,1430=>85,1450=>86,1480=>87,1500=>88,1525=>89,1540=>90,1560=>91,1580=>92,1600=>93,1620=>94,1640=>95,1660=>96,1680=>97,1690=>98,1700=>99,1710=>100,1720=>101,1745=>102,1770=>103,1785=>104,1800=>105,1815=>106,1830=>107,1845=>108,1860=>109,1875=>110}
      # $noise=$db->cleanString( self::tableCalibration( $dbTable, $dataObj->noise ) * 100 );
      ob.data.temp = round(-53 + 175.72 / 65536.0 * ob.data.temp, 1) * 10;
      ob.data.hum = round(7 + 125.0 / 65536.0  * ob.data.hum, 1) * 10;

    elsif o.hardware_version >= 10 && o.firmware_version >= 85 && o.firmware_param =~ /[AB]/
      db2 = {5 => 45,10 => 55,15 => 63,20 => 65,30 => 67,40 => 69,50 => 70,60 => 71,80 => 72,90 => 73,100 => 74,130 => 75,160 => 76,190 => 77,220 => 78,260 => 79,300 => 80,350 => 81,410 => 82,450 => 83,550 => 84,600 => 85,650 => 86,750 => 87,850 => 88,950 => 89,1100 => 90,1250 => 91,1375 => 92,1500 => 93,1650 => 94,1800 => 95,1900 => 96,2000 => 97,2125 => 98,2250 => 99,2300 => 100,2400 => 101,2525 => 102,2650 => 103}
      # $noise=$db->cleanString( self::tableCalibration( $dbTable, $dataObj->noise ) * 100 );
    end

    o.data.temp = [-300,o.data.temp,500].sort[1]
    o.data.hum = [0,o.data.temp,1000].sort[1]
    o.data.noise = [0,o.data.noise,16000].sort[1]
    o.data.noise = [0,o.data.bat,1000].sort[1]

    Rails.logger.info o
  end

# # function tableCalibration( $refTable, $rawValue ) {
# #   for ( $i=0; $i < sizeof( $refTable )-1; $i++ ) {
# #     $prevValueRef = $refTable[$i][0];
# #     $nextValueRef = $refTable[$i+1][0];
# #     if ( $rawValue >= $prevValueRef && $rawValue < $nextValueRef ) {
# #       $prevValueOutput = $refTable[$i][1];
# #       $nextValueOutput = $refTable[$i+1][1];
# #       $result = self::linear_regression( $rawValue, $prevValueOutput, $nextValueOutput, $prevValueRef, $nextValueRef );
# #       return round($result, 3);
# #     }
# #   }
# # }
# # function linear_regression( $valueInput, $prevValueOutput, $nextValueOutput, $prevValueRef, $nextValueRef ) {
# #   $slope = ( $nextValueOutput - $prevValueOutput ) / ( $nextValueRef - $prevValueRef );
# #   $result = $slope * ( $valueInput - $prevValueRef ) + $prevValueOutput;
# #   return $result;
# # }

#   def accept
#     # if ( $dataObj->timestamp=='#' ) return FALSE;
#     # if ( is_numeric( $dataObj->timestamp ) ) return FALSE;
#     # $datestr = $dataObj->timestamp;
#     # $todaystr = date( "Y-m-d H:i" );
#     # $today = strtotime( $todaystr );
#     # $date = strtotime( $datestr );
#     # if ( $date > ( $today+( 60*60*24 ) ) ) return FALSE;
#     # if ( $date < ( $today-( 60*60*24*365 ) ) ) return FALSE;

#     # //TODO MIRAR PER SI DE CAS // move the calibrate functions here. missed. sorry.
#     # //if ( $dataObj->temp>1000 )return FALSE;
#     # //if ( $dataObj->hum>1000 )return FALSE;
#     # //if($dataObj->light>1000)return FALSE;
#     # //if ( $dataObj->noise>12000 )return FALSE;
#     # if ( $dataObj->bat>1000 )return FALSE;
#     # if ( $dataObj->nets>200 )return FALSE;
#     # if ( $dataObj->hum<0 )return FALSE;
#     # if ( $dataObj->light<0 )return FALSE;
#     # if ( $dataObj->noise<0 )return FALSE;
#     # if ( $dataObj->bat<0 )return FALSE;
#     # if ( $dataObj->nets<0 )return FALSE;
#   end

end
