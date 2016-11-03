module MqttHandler
  # sets clean_session flag as false, sets client_id
  class ClientConnection < EventMachine::MQTT::ClientConnection
    def initialize(args={})
      super
      @client_id = "smartcitizen_1"
      @clean_session = false
    end
  end

  class ReadingsPacket
    # takes a packet and stores data
    def self.store(packet)
      device = Device.find_by(device_token: self.device_token(packet))

      return if device.nil?

      self.data(packet).each do |reading|
        Storer.new(device.id, reading)
      end
    rescue Exception => e
      puts e
      # Airbrake.notify(e)
    end

    # takes a packet and returns 'device token' from topic
    def self.device_token(packet)
      packet.topic[/device\/sck\/(.*?)\/readings/m, 1].to_s
    end

    # takes a packet and returns 'data' from payload
    def self.data(packet)
      JSON.parse(packet.payload)['data']
    end
  end
end
