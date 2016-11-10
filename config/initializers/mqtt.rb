Thread.new do
  EventMachine::error_handler { |e| Airbrake.notify(e) }

  EventMachine.run do
    EventMachine::MQTT::ClientConnection.connect(host: ENV['mqtt_host'], clean_session: true) do |c|
      c.subscribe({
        '$queue/device/sck/+/readings' => 1,
        '$queue/device/sck/+/hello' => 1
      })

      c.receive_callback do |packet|
        MqttMessagesHandler.handle(packet)
      end
    end
  end
end
