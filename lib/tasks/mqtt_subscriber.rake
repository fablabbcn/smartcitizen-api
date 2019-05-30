namespace :mqtt do
  task :sub => :environment do
    pid_file = Rails.root.join('tmp/pids/mqtt_subscriber.pid')
    File.open(pid_file, 'w'){|f| f.puts Process.pid}

    # Use docker container 'mqtt' if not defined
    host = ENV['mqtt_host'] || 'mqtt'

    begin
      p ("Connecting to #{host} ...");
      MQTT::Client.connect(host: host, clean_session: true) do |client|
        p ("Connected to #{client.host}");

        client.subscribe({
          '$queue/device/sck/+/readings' => 2,
          '$queue/device/sck/+/hello' => 2,
          '$queue/device/sck/+/info' => 2,
          '$queue/device/inventory' => 2
        })

        client.get do |topic, message|
          begin
            MqttMessagesHandler.handle_topic topic, message
          rescue Exception => e
            Raven.capture_exception(e)
            p e
          end
        end
      end
    rescue SystemExit, Interrupt, SignalException
      File.delete pid_file
      exit 0
    rescue Exception => e
      begin
        Raven.capture_exception(e)
        p e
        p ("Try to reconnect in 10 seconds...")
        sleep 10
        retry
      rescue SystemExit, Interrupt, SignalException
        File.delete pid_file
        exit 0
      end
    end
  end
end
