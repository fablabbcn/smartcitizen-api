Thread.new do
  EventMachine::error_handler { |e| Airbrake.notify(e) }

  EventMachine.run do
    EventMachine::MQTT::ClientConnection.connect(host: ENV['mqqt_host'], clean_session: true) do |c|
      c.subscribe('$queue/device/sck/+/readings')
      c.subscribe('$queue/device/sck/+/hello')
      c.receive_callback do |packet|
        if packet.topic.to_s.include?('readings')
          MqttReadingsHandler.store(packet)
        else
          Redis.current.publish('token_received', {
            device_token: MqttReadingsHandler.device_token(packet)
          }.to_json)
        end
      end
    end
  end
end
