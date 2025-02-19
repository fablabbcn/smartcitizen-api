class CSVUploadJob < ApplicationJob
  queue_as :default

  def perform(device_id, csv_data)
    parsed = parser.parse(csv_data)
    SendToDatastoreJob.perform_now(parsed.to_json, device_id)
  end

  def parser
    @parser ||= DataCSVParser.new
  end
end
