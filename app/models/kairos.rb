require 'net/http'
require 'uri'

class Kairos

  def self.get_timespan q
    return case q
      when "y" then "years"
      when "M" then "months"
      when "w" then "weeks"
      when "d" then "days"
      when "h" then "hours"
      when "m" then "minutes"
      when "s" then "seconds"
      when "ms" then "milliseconds"
    end
  end

  def self.create_from_api mac, data
    # self.ingest(mac, data.except('timestamp'), extract_datetime(data['timestamp']))
    Calibrator.new(self) if raw_data.present? and data.blank?
  end

  def self.query params

    rollup_value = params[:rollup].to_i
    rollup_unit = Kairos.get_timespan( params[:rollup].gsub(rollup_value.to_s,'') )

    data = {
      metrics: [
        {
          tags: {
            s: [
              params[:sensor_id]
            ]
          },
          name: "d#{params[:device_id]}",
          aggregators: [
            {
              name: params[:function],
              align_sampling: true,
              sampling: {
                value: rollup_value,#"1",
                unit: rollup_unit #"days"
              }
            }
          ]
        }
      ],
      cache_time: 0
    }

    if params[:relative]
      timespan_value = params[:relative].to_i
      timespan_unit = Kairos.get_timespan( params[:relative].gsub(timespan_value.to_s,'') )
    else
      timespan_value = 2
      timespan_unit = 'months'
    end
    data['start_relative'] = {
      value: timespan_value,
      unit: timespan_unit
    }

    response = self.http_post_to("/datapoints/query", data)
    j = JSON.parse(response.body)['queries'][0]

    json = {
      device_id: params[:device_id].to_i,
      sensor_id: params[:sensor_id].to_i,
      rollup: params[:rollup],
      function: params[:function],
      sample_size: j['sample_size'],
      from: timespan_value.send(timespan_unit).ago,
      to: Time.now.utc
    }
    readings = j['results'][0]['values'].map{|r| [Time.at(r[0]/1000).utc, r[1]]}
    json['readings'] = readings.reverse
    return json

  end

  def self.ingest device_id, data, recorded_at
    _data = []
    recorded_at = self.extract_datetime(recorded_at).to_i * 1000
    data.delete_if{|k,v| k.nil?}.each do |k,v|
      _data.push({
        name: "d#{device_id}",
        timestamp: recorded_at,
        value: v,
        tags: {"s":k}
      })
    end
    Rails.logger.info(device_id)
    Rails.logger.info(_data)
    response = self.http_post_to("/datapoints", _data)
  end

private

  def self.http_post_to path, data
    uri = URI.parse "http://kairos.server.smartcitizen.me/api/v1#{path}"
    Rails.logger.info(uri)
    headers = {"Content-Type" => "application/json",'Accept' => "application/json"}
    http = Net::HTTP.new(uri.host,uri.port)
    response = http.post(uri.path,data.to_json,headers)
  end

  def self.extract_datetime timestamp
    begin
      Time.parse(timestamp)
    rescue
      Time.at(timestamp)
    end
  end

end