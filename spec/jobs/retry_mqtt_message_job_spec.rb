require 'rails_helper'

RSpec.describe RetryMQTTMessageJob, type: :job do
  it "retries the mqtt ingest with the given topic and message, and with automatic retries disabled" do
    topic = "topic/1/2/3"
    message = '{"foo": "bar", "test": "message"}'
    expect(MqttMessagesHandler).to receive(:handle_topic).with(topic, message, false).and_return(true)
    RetryMQTTMessageJob.perform_now(topic, message)
  end

  it "raises an error if the handler returns nil" do
    topic = "topic/1/2/3"
    message = '{"foo": "bar", "test": "message"}'
    expect(MqttMessagesHandler).to receive(:handle_topic).with(topic, message, false).and_return(nil)
    expect {
      RetryMQTTMessageJob.perform_now(topic, message)
    }.to raise_error
  end
end
