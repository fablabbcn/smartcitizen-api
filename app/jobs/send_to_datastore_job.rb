class SendToDatastoreJob < ActiveJob::Base
  queue_as :default

  def perform(data_param, device_id)

    @device = Device.includes(:components).find(device_id)

    the_data = JSON.parse(data_param)
    the_data.sort_by {|a| a['recorded_at']}.reverse.each_with_index do |reading, index|
      # move to async method call
      do_update = index == 0
      Storer.new(@device, reading, do_update)
    end

  end
end
