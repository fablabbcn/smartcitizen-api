require 'rails_helper'

RSpec.describe RetryMQTTMessageJob, type: :job do
  include ActiveJob::TestHelper

  it "retries the mqtt ingest with the given topic and message, and with automatic retries disabled" do
    topic = "topic/1/2/3"
    message = '{"foo": "bar", "test": "message"}'
    expect(MqttMessagesHandler).to receive(:handle_topic).with(topic, message, false).and_return(true)
    RetryMQTTMessageJob.perform_now(topic, message)
  end

  it "retries if the handler returns nil" do
    topic = "topic/1/2/3"
    message = '{"foo": "bar", "test": "message"}'
    expect(MqttMessagesHandler).to receive(:handle_topic).with(topic, message, false).and_return(nil, nil, true)
    assert_performed_jobs 3 do
      RetryMQTTMessageJob.perform_later(topic, message)
    end
  end
end
