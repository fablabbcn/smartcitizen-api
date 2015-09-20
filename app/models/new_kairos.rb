class NewKairos < Kairos

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
      component_id: component.id,
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

    readings = j['results'][0]['values'].map{|r| [Time.at(r[0]/1000).utc, component.calibrated_value(r[1]) ]}

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

end