require 'net/http'
require 'uri'

module V0
  class ReadingsController < ApplicationController

    skip_after_action :verify_authorized

    def index
      check_missing_params("rollup", "sensor_key||sensor_id") # sensor_key or sensor_id
      render json: NewKairos.query(params)
    end

    def create
      begin
        data = JSON.parse(request.headers['X-SmartCitizenData'])[0].merge({
          'mac' => request.headers['X-SmartCitizenMacADDR'],
          'version' => request.headers['X-SmartCitizenVersion'],
          'ip' => request.remote_ip
        })
        ENV['redis'] ? RawStorer.delay.new(data) : RawStorer.new(data)
      rescue Exception => e
        BadReading.create(data: data, remote_ip: request.headers['X-SmartCitizenIP'])
        notify_airbrake(e)
      end
      render json: Time.current.utc.strftime("UTC:%Y,%-m,%-d,%H,%M,%S#") # render time for SCK to sync clock
    end

    def csv_archive
      keys = %w(temp bat co) # hum light nets no2 noise panel
      data = {}
      keys.each_with_index do |key, index|
        query = {metrics:[{tags:{device:[params[:id]]},name: key}], cache_time: 0, start_absolute: 1262304000000}
        response = NewKairos.http_post_to("/datapoints/query",query)
        values = JSON.parse(response.body)['queries'][0]['results'][0]['values']
        values.each do |v|
          time = Time.at(v[0]/1000).utc
          data[time] ||= []
          data[time] << v
        end
      end
      data = data.map{|d| d.join(",")}.join("\n")
      if params[:inline]
        render text: data
      else
        send_data data, filename: "device-#{params[:id]}.csv", type: 'text/csv'
      end
    end

  end
end
