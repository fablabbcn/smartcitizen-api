include 'rubygems'
include 'em-mqtt'

# THREAD? BACKGROUND PROCESS?

EventMachine::error_handler { |e| puts "#{e}: #{e.backtrace.first}" }

EventMachine.run do
  EventMachine::MQTT::ClientConnection.connect(
    :host => 'host',
    :username => 'myuser',
    :password => 'mypass'
  ) do |c|
    c.subscribe('/device/sck/+/readings')
    c.receive_callback do |message|
      device = Device.find_by(device_token: message['device_token'])

      return unless DataInspector.validate(message[params]) || !device.nil?

      Storer.new(device.id, message['data'])
    rescue Exception => e
      notify_airbrake(e)
    end
  end
end

class DataInspector
  def self.validate(data)
    # ensure received data meets requirements
    true # || false
  end
end
