namespace :mqtt do
  task :sub => :environment do
    client = MQTT::Client.connect(host: '127.0.0.1', clean_session: true)
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
