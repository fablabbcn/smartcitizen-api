require 'rails_helper'

RSpec.describe RetryMQTTMessageJob, type: :job do
  include ActiveJob::TestHelper

  let(:handler_results) { [true] }

  let(:mqtt_message_handler) {
    double(:mqtt_message_handler).tap do |mqtt_message_handler|
      allow(mqtt_message_handler).to receive(:handle_topic).and_return(*handler_results)
    end
  }

  let(:topic) { "topic/1/2/3" }

  let(:message) { '{"foo": "bar", "test": "message"}' }

  before do
    allow(MqttMessagesHandler).to receive(:new).and_return(mqtt_message_handler)
  end

  it "creates an MQTTMessagesHandler" do
    RetryMQTTMessageJob.perform_now(topic, message)
    expect(MqttMessagesHandler).to have_received(:new)
  end

  it "retries the mqtt ingest with the given topic and message, and with automatic retries disabled" do
    RetryMQTTMessageJob.perform_now(topic, message)
    expect(mqtt_message_handler).to have_received(:handle_topic).with(topic, message, false)
  end

  context "when the handler returns nil" do
    let(:handler_results) { [nil, nil, true] }

    it "retries when the handler returns nil" do
      assert_performed_jobs 3 do
        RetryMQTTMessageJob.perform_later(topic, message)
      end
    end
  end
end
