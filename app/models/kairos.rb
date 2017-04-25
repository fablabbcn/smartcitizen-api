# This is going to be removed from app/models and refactored into lib/.
# It is the interface between the KairosDB HTTP REST API and this app. When
# performing bulk operations with Kairos it's probably better to use telnet
# https://kairosdb.github.io/docs/build/html/PushingData.html

require 'net/http'
require 'uri'

class Kairos

  def self.query params

    function = params[:function] || "avg"

    rollup_value = params[:rollup].to_i
    rollup_unit = Kairos.get_timespan( params[:rollup].gsub(rollup_value.to_s,'') )

    device = Device.find(params[:id])

    if sensor_key = params[:sensor_key]
      sensor_id = device.find_sensor_id_by_key(params[:sensor_key])
    else
      sensor_id = params[:sensor_id].try(:to_i)
      sensor_key = device.find_sensor_key_by_id(sensor_id.to_i)
    end

    component = device.find_component_by_sensor_id(sensor_id)


    metrics = [{
      tags: { device_id: params[:id] },
      name: sensor_key,
      aggregators: [
        {
          name: function,
          align_sampling: true,
          sampling: {
            value: rollup_value,#"1",
            unit: rollup_unit #"days"
          }
        }
      ]
    }]

    data = { metrics: metrics, cache_time: 0 }

    json = {
      device_id: params[:id].to_i,
      sensor_key: sensor_key,
      sensor_id: sensor_id,
      component_id: component.try(:id),
      rollup: params[:rollup],
      function: function
    }

    if params[:from]
      begin
        data['start_absolute'] = Time.parse(params[:from]).to_i * 1000
      rescue
        data['start_absolute'] = Time.at(params[:from])
      end

      if params[:to]
        begin
          data['end_absolute'] = Time.parse(params[:to]).to_i * 1000
        rescue
          data['end_absolute'] = Time.at(params[:to])
        end
      else
        data['end_absolute'] = Time.now.to_i * 1000
      end

      json['from'] = Time.at( data['start_absolute'] / 1000 ).utc
      json['to'] = Time.at( data['end_absolute'] / 1000 ).utc

    else
      if params[:relative]
        timespan_value = params[:relative].to_i
        timespan_unit = Kairos.get_timespan( params[:relative].gsub(timespan_value.to_s,'') )
      else
        timespan_value = 6
        timespan_unit = 'weeks'
      end

      data['start_relative'] = {
        value: timespan_value,
        unit: timespan_unit
      }
      json['from'] = timespan_value.send(timespan_unit).ago
      json['to'] = Time.now.utc

    end

    response = self.http_post_to("/datapoints/query", data)

    # puts data.to_json

    if response.body
      j = JSON.parse(response.body)['queries'][0]
    else
      raise "No response.body"
    end

    json['sample_size'] = j['sample_size']

    if params[:raw]
      readings = j['results'][0]['values'].map{|r| [Time.at(r[0]/1000).utc, r[1] ]}
    else
      readings = j['results'][0]['values'].map{|r| [Time.at(r[0]/1000).utc, component.calibrated_value(r[1]) ]}
    end

    if rollup_value.send(rollup_unit) >= 10.minutes && params[:all_intervals]
      # json['readings'] = readings
      distance = rollup_value.send(rollup_unit)
      percent = rollup_value.send(rollup_unit) * 0.1
      time_iterate(json['from'], json['to'], distance ) do |t|
        readings << [t, nil]
      end
      json['readings'] = []
      readings = readings.sort_by{|t| t[0]}

      while readings.length > 0
        this_reading = readings.pop
        if readings.length > 0
          next_reading = readings.last
          if next_reading[0] - this_reading[0] < percent
            next_reading = readings.pop
            json['readings'] << [next_reading[0], [this_reading[1], next_reading[1]].max_by(&:to_i)]
          else
            json['readings'] << this_reading
          end
        end
      end

    else
      json['readings'] = readings.sort_by{|t| t[0]}.reverse
    end

    return json
  end

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

  def self.legacy_query params
    function = params[:function] || "avg"

    rollup_value = params[:rollup].to_i
    rollup_unit = Kairos.get_timespan( params[:rollup].gsub(rollup_value.to_s,'') )

    metrics = []
    params[:sensor_ids].each do |sensor_id|

      metrics << {
        tags: {
          s: [sensor_id]
        },
        name: "d#{params[:device_id]}",
        aggregators: [
          {
            name: function,
            align_sampling: true,
            sampling: {
              value: rollup_value,#"1",
              unit: rollup_unit #"days"
            }
          }
        ]
      }

    end

    data = {
      metrics: metrics,
      cache_time: 0
    }

    # json = {
    #   device_id: params[:device_id].to_i,
    #   sensor_id: params[:sensor_id].to_i,
    #   rollup: params[:rollup],
    #   function: function
    # }

    if params[:from]
      begin
        data['start_absolute'] = Time.parse(params[:from]).to_i * 1000
      rescue
        data['start_absolute'] = Time.at(params[:from])
      end

      if params[:to]
        begin
          data['end_absolute'] = Time.parse(params[:to]).to_i * 1000
        rescue
          data['end_absolute'] = Time.at(params[:to])
        end
      else
        data['end_absolute'] = Time.now.to_i * 1000
      end

      # json['from'] = Time.at( data['start_absolute'] / 1000 ).utc
      # json['to'] = Time.at( data['end_absolute'] / 1000 ).utc

    else
      if params[:relative]
        timespan_value = params[:relative].to_i
        timespan_unit = Kairos.get_timespan( params[:relative].gsub(timespan_value.to_s,'') )
      else
        timespan_value = 6
        timespan_unit = 'weeks'
      end

      data['start_relative'] = {
        value: timespan_value,
        unit: timespan_unit
      }
      # json['from'] = timespan_value.send(timespan_unit).ago
      # json['to'] = Time.now.utc

    end

    # Rails.logger.info data.to_json

    response = self.http_post_to("/datapoints/query", data)
    j = JSON.parse(response.body)
    results = []
    j['queries'][0]['results'][0]['values'].collect.with_index do |x,i|
      time = Time.at(x[0]/1000)
      h = {
        date: "#{time.to_date} UTC",
        hour: time.hour.to_s
      }
      params[:sensor_ids].each_with_index do |k,l|
        h[LegacyDevice::KEYS[k.to_s.to_sym]] = j['queries'][l]['results'][0]['values'][i][1]
      end
      results << h
    end
    results
  end

  def self.ingest device_id, data, recorded_at
    _data = []
    recorded_at = self.extract_datetime(recorded_at).to_i * 1000
    data.delete_if{|k,v| k.nil?}.each do |k,v|
      _data.push({
        name: "d#{device_id}",
        timestamp: recorded_at,
        value: (Float(v) rescue v),
        tags: {"s":k}
      })
    end
    Rails.logger.info(device_id)
    Rails.logger.info(_data)
    response = self.http_post_to("/datapoints", _data)
  end

  def self.http_post_to path, data
    domain = "http://#{[ ENV['kairos_server'], ENV['kairos_port'] ].reject(&:blank?).join(':')}"
    uri = URI.parse "#{domain}/api/v1#{path}"
    Rails.logger.info(uri)
    http = Net::HTTP.new(uri.host,uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.basic_auth(ENV['kairos_http_username'], ENV['kairos_http_password'])
    request.add_field('Content-Type', 'application/json')
    request.add_field('Accept', 'application/json')
    request.body = data.to_json
    response = http.request(request)
    return response
  end

protected

  def self.time_iterate(start_time, end_time, step, &block)
    begin
      yield(start_time)
    end while (start_time += step) <= end_time
  end

  def self.extract_datetime timestamp
    begin
      Time.parse(timestamp)
    rescue
      Time.at(timestamp)
    end
  end

end
