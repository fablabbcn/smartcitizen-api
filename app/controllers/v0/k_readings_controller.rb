require 'net/http'
# require 'cgi'

# require 'open-uri'
require 'uri'

module V0
  class KReadingsController < ApplicationController

  skip_after_action :verify_authorized

    def index
      uri = "http://kairos.server.smartcitizen.me:8080/api/v1/datapoints/query"
      p = {
        metrics: [
          {
            tags: {
              s: [
                "7"
              ]
            },
            name: "d#{params[:device_id]}",
            aggregators: [
              {
                name: "avg",
                align_sampling: true,
                sampling: {
                  value: "1",
                  unit: "days"
                }
              }
            ]
          }
        ],
        cache_time: 0,
        start_relative: {
          value: "5",
          unit: "months"
        }
      }


      # response = Unirest.get uri,
      #   headers: { "Content-Type": "application/json"},
      #   parameters: params.to_json
      # # uri.query = URI.encode_www_form( params )


  # uri = URI.parse('http://kairos.server.smartcitizen.me/api/v1/datapoints/query')
  # response = Net::HTTP.post_form(uri, params)
  # render text: response.body

headers = {
"Accept" => "application/json",
"Accept-Encoding" => "gzip, deflate",
"Connection" => "keep-alive",
"Content-Length" => "406",
"Content-Type" => "application/json; charset=utf-8",
"Host" => "kairos.server.smartcitizen.me:8080",
"User-Agent" => "HTTPie/0.9.1"
}

  # response = Unirest.post 'http://kairos.server.smartcitizen.me/api/v1/datapoints/query',
  #     headers: headers,
  #     parameters: params

  #     render text: response.to_json

    url = "http://kairos.server.smartcitizen.me/api/v1/datapoints/query"
    uri = URI.parse(url)

    headers = {"Content-Type" => "application/json",'Accept' => "application/json"}

    http = Net::HTTP.new(uri.host,uri.port)
    response = http.post(uri.path,p.to_json,headers)
    render json: response.body

      # render text: response.raw_body
      # render json: {
      #   rollup: "1d",
      #   function: "average",
      #   from: "2015-06-05T20:29:37Z",
      #   to: "2015-07-05T20:29:37Z"
      # }
    end

  end
end
