namespace :mqtt do
  task :sub => :environment do
    host = Figaro.env.mqtt_host!
    Rails.logger.info("Try to connect to #{host} ...");
    MQTT::Client.connect(host: host, clean_session: true) do |client|
      Rails.logger.info("Mqtt subscriber connected to: #{client.host}");

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
end
