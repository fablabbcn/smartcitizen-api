class Influx < ActiveRecord::Base

  def self.http_post_to database, data

    # TODO: TLS
    #request.basic_auth(ENV['influx_http_username'], ENV['influx_http_password'])
    domain = ENV['influx_path']
    uri = URI.parse "#{domain}/write?db=#{database}"

    http = Net::HTTP.new(uri.host,uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)

    data = data.first
    # Influx accepts timestamp in nanoseconds, 19 digits
    request.body = "#{data[:name]},device_id=#{data[:tags][:device_id]},method=#{data[:tags][:method]} #{data[:name]}=#{data[:value]} #{data[:timestamp]*1000000}"

    response = http.request(request)

    # response.body can return errors such as: 4xx Bad Request
    # {\"error\":\"unable to parse 'light,device_id=1,REST light=10.6478972749005 1537996091000000000': missing tag value\"}\n"
    return response
  end

end
