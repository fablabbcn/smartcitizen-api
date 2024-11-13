class SendToDatastoreJob < ApplicationJob
  queue_as :default

  def perform(data_param, device_id)
    @device = Device.includes(:components).find(device_id)
    readings = JSON.parse(data_param)
    storer.store(@device, readings)
  end

  def storer
    @storer ||= Storer.new
  end
end
