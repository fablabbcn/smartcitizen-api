Thread.new do
  EventMachine::error_handler { |e| puts "#{e}: #{e.backtrace.first}" }

  EventMachine.run do
    MqttHandler::ClientConnection.connect('127.0.0.1') do |c|
      c.subscribe('device/sck/+/readings')
      c.receive_callback do |packet|
        MqttHandler::ReadingsPacket.store(packet)
      end
    end
  end
end
