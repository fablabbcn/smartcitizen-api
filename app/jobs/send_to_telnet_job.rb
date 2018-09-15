class SendToTelnetJob < ActiveJob::Base
  queue_as :default

  def perform(the_data, device)

    the_data.sort_by {|a| a['recorded_at']}.reverse.each_with_index do |reading, index|
      # move to async method call
      do_update = index == 0
      Storer.new(device, reading, do_update)
    end

  end
end
