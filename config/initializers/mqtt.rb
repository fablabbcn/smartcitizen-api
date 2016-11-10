Thread.new do
  EventMachine::error_handler { |e| Airbrake.notify(e) }

  EventMachine.run do
    EventMachine::MQTT::ClientConnection.connect(host: ENV['mqtt_host'], clean_session: true) do |c|
      c.subscribe('$queue/device/sck/+/readings')
      c.subscribe('$queue/device/sck/+/hello')

      c.receive_callback do |packet|
        MqttMessagesHandler.handle(packet)
      end
    end
  end
end
