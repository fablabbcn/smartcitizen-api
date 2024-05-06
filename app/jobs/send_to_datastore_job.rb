class SendToDatastoreJob < ApplicationJob
  queue_as :default

  def perform(data_param, device_id)
    begin
      @device = Device.includes(:components).find(device_id)
      the_data = JSON.parse(data_param)
      the_data.sort_by {|a| a['recorded_at']}.reverse.each_with_index do |reading, index|
        # move to async method call
        do_update = index == 0
        storer.store(@device, reading, do_update)
      end
    ensure
      disconnect_mqtt
    end
  end

  def storer
    @storer ||= Storer.new(mqtt_client, ActionController::Base.new.view_context)
  end

  def mqtt_client
    @mqtt_client ||= MQTTClientFactory.create_client({clean_session: true, client_id: nil })
  end

  def disconnect_mqtt
    @mqtt_client&.disconnect
  end
end
