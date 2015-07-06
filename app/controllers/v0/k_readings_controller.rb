require 'net/http'
# require 'cgi'

# require 'open-uri'
require 'uri'

module V0
  class KReadingsController < ApplicationController

  skip_after_action :verify_authorized

    def index
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

      uri = "http://kairos.server.smartcitizen.me:8080/api/v1/datapoints/query"
      p = {
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

    url = "http://kairos.server.smartcitizen.me/api/v1/datapoints/query"
    uri = URI.parse(url)

    headers = {"Content-Type" => "application/json",'Accept' => "application/json"}

    http = Net::HTTP.new(uri.host,uri.port)
    response = http.post(uri.path,p.to_json,headers)
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
    # response.body
    render json: json

    end

  end
end
