require 'json'
require 'net/http'
require 'uri'

class RawStorerIngestor

  def initialize request=nil
    begin
      ip = (request.headers['X-SmartCitizenIP'] || request.remote_ip)
      mac = request.headers['X-SmartCitizenMacADDR']
      version = request.headers['X-SmartCitizenVersion']
      JSON.parse(request.headers['X-SmartCitizenData']).each do |raw_reading|
        if ENV['redis']
          RawStorer.delay(retry: false).new(raw_reading,mac,version,ip)
        else
          RawStorer.new(raw_reading,mac,version,ip)
        end
      end
    rescue => e
      Airbrake.notify_or_ignore(
        e,
        error_class: 'readings',
        parameters: request.try(:to_hash),
        cgi_data: ENV.to_hash
      )
    end
  end

end
