Thread.new { EventMachine.run }

EventMachine.next_tick do
  EventMachine::error_handler do |e| 
    Airbrake.notify(e)
  end

  EventMachine::MQTT::ClientConnection.connect(host: '127.0.0.1', clean_session: true) do |c|
    c.subscribe({
      '$queue/device/sck/+/readings' => 1,
      '$queue/device/sck/+/hello' => 1
    })

    c.receive_callback do |packet|
      MqttMessagesHandler.handle(packet)
    end
  end
end
