class RetryMQTTMessageJob < ApplicationJob
  queue_as :default

  def perform(topic, message)
    result = MqttMessagesHandler.handle_topic(topic, message, false)
    raise "Message handler returned nil, retrying" if result.nil?
  end
end


