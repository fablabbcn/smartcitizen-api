require 'rails_helper'

RSpec.describe MQTTForwardingJob, type: :job do

  let(:forwarding_token) { "abc123_forwarding_token" }

  let(:device) { create(:device) }

  let(:readings) { double(:readings) }

  let(:mqtt_client) {
    double(:mqtt_client).tap do |mqtt_client|
      allow(mqtt_client).to receive(:disconnect)
    end
  }

  let(:device_json) {
    double(:device_json)
  }

  let(:device_representation) {
    double(:device_representation).tap do |device_representation|
      allow(device_representation).to receive(:to_json).and_return(device_json)
    end
  }

  let(:forwarder) {
    double(:forwarder).tap do |forwarder|
      allow(forwarder).to receive(:forward_readings)
    end
  }

  before do
    allow(MQTTClientFactory).to receive(:create_client).and_return(mqtt_client)
    allow(Presenters).to receive(:present).and_return(device_representation)
    allow(MQTTForwarder).to receive(:new).and_return(forwarder)
    allow_any_instance_of(Device).to receive(:forwarding_token).and_return(forwarding_token)
  end

  it "creates an mqtt client with a clean session and no client id" do
    MQTTForwardingJob.perform_now(device.id, readings: readings)
    expect(MQTTClientFactory).to have_received(:create_client).with({
      clean_session: true,
      client_id: nil
    })
  end

  it "creates a forwarder with the mqtt client" do
    MQTTForwardingJob.perform_now(device.id, readings: readings)
    expect(MQTTForwarder).to have_received(:new).with(mqtt_client)
  end

  it "renders the device json for the given device and reading, as the device owner" do
    MQTTForwardingJob.perform_now(device.id, readings: readings)
    expect(Presenters).to have_received(:present).with(device, device.owner, nil, readings: readings)
  end

  it "forwards using the device's id and forwarding token, with the rendered json payload" do
    MQTTForwardingJob.perform_now(device.id, readings: readings)
    expect(forwarder).to have_received(:forward_readings).with(forwarding_token, device.id, device_json)
  end

  it "disconnects the MQTT client" do
    MQTTForwardingJob.perform_now(device.id, readings: readings)
    expect(mqtt_client).to have_received(:disconnect)
  end

end
