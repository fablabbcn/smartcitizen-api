namespace :mqtt do
  task :sub => :environment do

    # if Rails.env.production?
    #   Figaro.require_keys('mqtt_host')
    # else
    #   ENV['mqtt_host'] = '127.0.0.1' if ENV['mqtt_host'].nil?
    # end

    # client = MQTT::Client.connect(host: ENV['mqtt_host'], clean_session: true)
    client = MQTT::Client.connect(host: '192.168.133.135', clean_session: true) # Hot fix for demo.
    client.subscribe({
      '$queue/device/sck/+/readings' => 2,
      '$queue/device/sck/+/hello' => 2
    })

    client.get do |topic, message|
      begin
        MqttMessagesHandler.handle_topic topic, message
      rescue Exception => e
        Rails.logger.error(e)
        Airbrake.notify(e)
      end
    end
  end
end
