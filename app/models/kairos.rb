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









  def self.query params

    function = params[:function] || "avg"

    rollup_value = params[:rollup].to_i
    rollup_unit = Kairos.get_timespan( params[:rollup].gsub(rollup_value.to_s,'') )


      metrics = [{
        tags: {
          s: [ params[:sensor_id] ]
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
      }]

    data = {
      metrics: metrics,
      cache_time: 0
    }

    json = {
      device_id: params[:id].to_i,
      sensor_id: params[:sensor_id].to_i,
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
    j = JSON.parse(response.body)['queries'][0]

    json['sample_size'] = j['sample_size']

    readings = j['results'][0]['values'].map{|r| [Time.at(r[0]/1000).utc, r[1]]}

    if rollup_value.send(rollup_unit) >= 10.minutes && params[:all_intervals]
      # json['readings'] = readings
      distance = rollup_value.send(rollup_unit)
      percent = rollup_value.send(rollup_unit) * 0.1
      time_iterate(json['from'], json['to'], distance ) do |t|
        readings << [t,nil]
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
            # json['readings'] << readings.pop
          end
        end
      end

    else
      json['readings'] = readings.sort_by{|t| t[0]}.reverse
    end

    return json
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

private

  def self.time_iterate(start_time, end_time, step, &block)
    begin
      yield(start_time)
    end while (start_time += step) <= end_time
  end

  def self.http_post_to path, data
    uri = URI.parse "http://#{[ ENV['kairos_server'], ENV['kairos_port'] ].reject(&:blank?).join(':')}/api/v1#{path}"
    # uri = URI.parse "http://#{ENV['kairos_server']}:8080/api/v1#{path}"
    Rails.logger.info(uri)
    headers = {"Content-Type" => "application/json",'Accept' => "application/json"}
    # http = Net::HTTP.new(uri.host,uri.port)
    http = Net::HTTP.new(uri.host,uri.port)
    response = http.post(uri.path,data.to_json,headers)

    # Rails.logger.info(response.inspect)
    # Rails.logger.info(data.to_json)

    return response
  end

  def self.extract_datetime timestamp
    begin
      Time.parse(timestamp)
    rescue
      Time.at(timestamp)
    end
  end

end


[{:name=>"d1356", :timestamp=>1438080463000, :value=>10.23517578125, :tags=>{:s=>12}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>23584, :tags=>{:s=>"12_raw"}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>68.9049072265625, :tags=>{:s=>13}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>32456, :tags=>{:s=>"13_raw"}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>0.0, :tags=>{:s=>14}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>0, :tags=>{:s=>"14_raw"}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>100.0, :tags=>{:s=>17}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>1000, :tags=>{:s=>"17_raw"}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>0, :tags=>{:s=>18}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>0, :tags=>{:s=>"18_raw"}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>92.087, :tags=>{:s=>16}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>92087, :tags=>{:s=>"16_raw"}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>0.0, :tags=>{:s=>15}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>0, :tags=>{:s=>"15_raw"}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>50.0, :tags=>{:s=>7}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>0, :tags=>{:s=>"7_raw"}}, {:name=>"d1356", :timestamp=>1438080463000, :value=>1, :tags=>{:s=>21}}]
