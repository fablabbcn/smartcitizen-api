require 'net/http'
require 'uri'

class Kairos

  def self.query params

    rollup_value = params[:rollup].to_i
    rollup_unit = case params[:rollup].gsub(rollup_value.to_s,'')
      when "y" then "years"
      when "M" then "months"
      when "w" then "weeks"
      when "d" then "days"
      when "h" then "hours"
      when "m" then "minutes"
      when "s" then "seconds"
      when "ms" then "milliseconds"
    end

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
      cache_time: 0,
      start_relative: {
        value: "6",
        unit: "months"
      }
    }

    response = self.http_post_to("/datapoints/query", data)

    j = JSON.parse(response.body)['queries'][0]

    json = {
      device_id: params[:device_id].to_i,
      sensor_id: params[:sensor_id].to_i,
      rollup: params[:rollup],
      function: params[:function],
      sample_size: j['sample_size'],
      from: 6.months.ago,
      to: Time.now.utc
    }
    readings = j['results'][0]['values'].map{|r| [Time.at(r[0]/1000).utc, r[1]]}
    json['readings'] = readings.reverse
    return json

  end

  def self.ingest device_id, data, recorded_at
    _data = []
    data.each do |k,v|
      _data.push({
        name: "d#{device_id}",
        timestamp: recorded_at.to_i * 1000,
        value: v,
        tags: {"s":k}
      })
    end
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

end