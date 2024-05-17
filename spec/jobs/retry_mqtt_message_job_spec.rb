require 'rails_helper'

RSpec.describe HandleIncomingMQTTMessageJob, type: :job do
  include ActiveJob::TestHelper

  let(:mqtt_client) {
    double(:mqtt_client).tap do |mqtt_client|
      allow(mqtt_client).to receive(:disconnect)
    end
  }

  let(:handler_results) { [true] }

  let(:mqtt_message_handler) {
    double(:mqtt_message_handler).tap do |mqtt_message_handler|
      allow(mqtt_message_handler).to receive(:handle_topic).and_return(*handler_results)
    end
  }

  let(:topic) { "topic/1/2/3" }

  let(:message) { '{"foo": "bar", "test": "message"}' }

  before do
    allow(MQTTClientFactory).to receive(:create_client).and_return(mqtt_client)
    allow(MqttMessagesHandler).to receive(:new).and_return(mqtt_message_handler)
  end

  it "creates an MQTTMessagesHandler" do
    HandleIncomingMQTTMessageJob.perform_now(topic, message)
    expect(MqttMessagesHandler).to have_received(:new)
  end

  it "retries the mqtt ingest with the given topic and message" do
    HandleIncomingMQTTMessageJob.perform_now(topic, message)
    expect(mqtt_message_handler).to have_received(:handle_topic).with(topic, message)
  end
end
