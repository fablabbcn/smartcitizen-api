require 'json'
require 'net/http'
require 'uri'

class ReadingStorer

  def initialize smart_headers
    smart_headers.each do |raw_reading|
      begin
        mac = request.headers['X-SmartCitizenMacADDR']
        version = request.headers['X-SmartCitizenVersion']
        ip = (request.headers['X-SmartCitizenIP'] || request.remote_ip)
        if ENV['redis']
          RawStorer.delay(retry: false).new(raw_reading,mac,version,ip)
        else
          RawStorer.new(raw_reading,mac,version,ip)
        end
      rescue => e
        Airbrake.notify_or_ignore(
          e,
          error_class: 'readings',
          parameters: params,
          cgi_data: ENV.to_hash
        )
      end
    end
  end

end
