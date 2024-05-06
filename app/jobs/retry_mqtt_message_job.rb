class RetryMQTTMessageJob < ApplicationJob
  queue_as :mqtt_retry

  sidekiq_retry_in do |count|
   case count
   when 0..10 # Every 30 seconds for the first 5 minutes
    30.seconds
   when 11..55 # Then every minute for an hour
     1.minute
   else
     false # Fallback to default backoff after an hour,
       # see https://github.com/sidekiq/sidekiq/issues/2338
   end
  end

  def perform(topic, message)
    result = MqttMessagesHandler.handle_topic(topic, message, false)
    raise "Message handler returned nil, retrying" if result.nil?
  end
end


