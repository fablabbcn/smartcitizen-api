namespace :mqtt do
  task sub: :environment do
    pid_file = Rails.root.join('tmp/pids/mqtt_subscriber.pid')
    File.open(pid_file, 'w') { |f| f.puts Process.pid }
    mqtt_log = Logger.new('log/mqtt.log', 5, 100.megabytes)
    mqtt_log.info('MQTT TASK STARTING')

    # Use docker container 'mqtt' if not defined
    host = ENV['mqtt_host'] || 'mqtt'

    begin
      mqtt_log.info "Connecting to #{host} ..."
      MQTT::Client.connect(host: host, clean_session: true) do |client|
        mqtt_log.info "Connected to #{client.host}"

        client.subscribe(
          '$queue/device/sck/+/readings' => 2,
          '$queue/device/sck/+/hello' => 2,
          '$queue/device/sck/+/info' => 2,
          '$queue/device/inventory' => 2
        )

        client.get do |topic, message|
          MqttMessagesHandler.handle_topic topic, message
        rescue Exception => e
          mqtt_log e
          Raven.capture_exception(e)
        end
      end
    rescue SystemExit, Interrupt, SignalException
      File.delete pid_file
      exit 0
    rescue Exception => e
      begin
        Raven.capture_exception(e)
        mqtt_log.info e
        mqtt_log.info "Try to reconnect in 10 seconds..."
        sleep 10
        retry
      rescue SystemExit, Interrupt, SignalException
        File.delete pid_file
        exit 0
      end
    end
  end
end
