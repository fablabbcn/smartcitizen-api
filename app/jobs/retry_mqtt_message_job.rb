class RetryMQTTMessageJob < ApplicationJob
  class RetryMessageHandlerError < RuntimeError
  end

  queue_as :mqtt_retry


  retry_on(RetryMessageHandlerError, attempts: 75, wait: ->(count) {
    case count
    when 0..12
      5.seconds
    when 12..20 # Every 30 seconds for the first 5 minutes
      30.seconds
    else # Then every minute for an hour
      1.minute
    end
  }) do |_job, _exeception|
    # No-op, this block ensures the exception isn't reraised and retried by Sidekiq
  end

  def perform(topic, message)
    result = handler.handle_topic(topic, message, false)
    raise RetryMessageHandlerError if result.nil?
  end

  private

  def handler
    @handler ||= MqttMessagesHandler.new
  end
end

