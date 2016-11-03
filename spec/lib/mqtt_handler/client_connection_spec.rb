require 'rails_helper'

RSpec.describe MqttHandler::ClientConnection do
  it { expect(MqttHandler::ClientConnection).to be < EventMachine::MQTT::ClientConnection }

  it 'initializes with correct client_id and clean_session flag' do
    connection = MqttHandler::ClientConnection.new({})

    expect(connection.instance_variable_get('@client_id')).to eq('smartcitizen')
    expect(connection.instance_variable_get('@clean_session')).to eq(false)
  end
end
