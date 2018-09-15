require 'net/telnet'
require 'json'

namespace :telnet do
  task :push => :environment do
    localhost = Net::Telnet::new("Host" => ENV['kairos_server'], "Timeout" => 3, "Prompt" => /[$%#>] \z/n, "Port" => ENV['kairos_telnet_port'])
#    PgReading.find_in_batches do |batch|
#      batch.each do |reading|
#        device_id = reading.device_id
#        reading.data.each do |k,v|
#          if k.match(/\d$/)
#            # p [device_id, "s=#{k}", reading.recorded_at.to_i, v]
#            localhost.print "put d#{device_id}_s#{k} #{reading.recorded_at.to_i} #{v}\n"
#
#          end
#        end
#      end
    #end

    p 'Starting Redis subscription...'
    Redis.current.subscribe('telnet_queue') do |on|
      on.message do |channel, msg|
        #puts "#{channel} - #{msg}"
        data = JSON.parse(msg).first

        telnet_string = "put 'metric_telnet9' #{data['timestamp']} #{data['value']} device_id=#{data['tags']['device_id']} \n"
        localhost.print telnet_string
      end
    end

    #sleep(1)

    # loop do
    #   localhost.print("put testing #{Time.now.to_i} #{rand()}\n")
    #   puts "put testing #{Time.now.to_i} #{rand()}"
    #   sleep(1)
    # end
    localhost.close
  end
end
