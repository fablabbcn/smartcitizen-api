class RetryMQTTMessageJob < ApplicationJob
  queue_as :mqtt_retry

  sidekiq_retry_in do |count|
   case count
   when 0..12
     5.seconds
   when 12..20 # Every 30 seconds for the first 5 minutes
    30.seconds
   when 20..75 # Then every minute for an hour
     1.minute
   else
     :discard
   end
  end

  def perform(topic, message)
    result = MqttMessagesHandler.handle_topic(topic, message, false)
    raise "Message handler returned nil, retrying" if result.nil?
  end
end


