# TO BE REMOVED

module V0
  class PgReadingsController < ApplicationController

    skip_after_action :verify_authorized

    def to_f_or_i_or_s(v)
      ((float = Float(v)) && (float % 1.0 == 0) ? float.to_i : float) rescue v
    end

    def index
      @device = Device.find(params[:device_id])
      sensor_ids = @device.sensors.order('sensors.id ASC').pluck(:id)
      sensors = sensor_ids.map{ |id| "avg((data->>'#{id}')::numeric) AS sensor_#{id}" }.join(', ')

      PgReading.select("date_trunc('day', recorded_at) AS day, #{sensors}").group("1").order("1")

      to = params[:to] ? Time.parse(params[:to] + " UTC") : Time.now
      readings = []
      data = Hash[sensor_ids.map {|key, value| [key, nil]}]

      if params[:rollup] == '1h'
        select = "SELECT date_trunc('hour', recorded_at)::timestamp without time zone AS day"
        rollup = '1h'
        from = params[:from] ? Time.parse(params[:from]) : 1.week.ago
        if params[:all_intervals]
          time_iterate(from.beginning_of_hour, to.end_of_hour, 1.hour) do |t|
            readings << {
              timestamp: t,
              data: data
            }
          end
        end
      elsif params[:rollup] == '1m'
        select = "SELECT date_trunc('minute', recorded_at)::timestamp without time zone AS day"
        rollup = '1m'
        from = params[:from] ? Time.parse(params[:from]) : 1.hour.ago
        if params[:all_intervals]
          time_iterate(from.beginning_of_minute, to.end_of_minute, 1.minute) do |t|
            readings << {
              timestamp: t,
              data: data
            }
          end
        end
      else # day
        select = "SELECT date_trunc('day', recorded_at)::timestamp without time zone AS day"
        rollup = '1d'
        from = params[:from] ? Time.parse(params[:from]) : 1.month.ago
        if params[:all_intervals]
          time_iterate(from.beginning_of_day, to.end_of_day, 1.day) do |t|
            readings << {
              timestamp: t,
              data: data
            }
          end
        end
      end

      sql = %{
        SET TIME ZONE 'UTC';
        #{select},
        #{sensors}
        FROM pg_readings
        WHERE device_id = '#{@device.id}'
        AND recorded_at BETWEEN '#{from.utc.to_s}' AND '#{to.utc.to_s}'
        GROUP BY 1
        ORDER BY 1 DESC;
      }

      @pg_readings = ActiveRecord::Base.connection.execute(sql)

      ob = { rollup: rollup, function: 'average', from: from, to: to, readings: readings }

      @pg_readings.each do |reading|
        ob[:readings] = ob[:readings] - ob[:readings].select{|hash| hash[:timestamp] == Time.parse(reading['day'] + " UTC") }
        ob[:readings] << {
          timestamp: Time.parse(reading['day'] + " UTC"),
          data: reading.select { |key, value| key.to_s.match(/^sensor_\d+/) }.map{|k,v| [k.gsub('sensor_',''), to_f_or_i_or_s(v)] }.to_h
        }
      end

      ob[:readings].sort_by!{|a| a[:timestamp]}.reverse!

      render json: ob

      # PgReading.select("date_trunc('day', recorded_at) AS day, #{sensors}").group("1").order("1")

      # @pg_readings = @device.pg_readings
      # @pg_readings = paginate(@pg_readings)
    end

private

  def time_iterate(start_time, end_time, step, &block)
    begin
      yield(start_time)
    end while (start_time += step) <= end_time
  end


  end
end

# render text: %{
#   SELECT date_trunc('hour', recorded_at) AS hour,
#   (extract(minute FROM recorded_at)::int / 5) AS min5_slot,
#   #{sensors}
#   FROM pg_readings
#   GROUP BY 1, 2
#   ORDER BY 1, 2;
# }