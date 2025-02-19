require 'rails_helper'

RSpec.describe CSVUploadJob, type: :job do


  let(:device_id) { double(:device_id) }
  let(:csv_data) { double(:csv_data) }
  let(:parsed_json)  { double(:parsed_json) }

  let(:parsed)  { double(:parsed).tap do |parsed|
    allow(parsed).to receive(:to_json).and_return(parsed_json)
  end
  }

  let(:parser) {
    double(:parser).tap do |parser|
      allow(parser).to receive(:parse).and_return(parsed)
    end
  }

  before do
    allow(DataCSVParser).to receive(:new).and_return(parser)
    allow(SendToDatastoreJob).to receive(:perform_now)
  end


  it "parses the CSV data" do
    CSVUploadJob.perform_now(device_id, csv_data)
    expect(parser).to have_received(:parse).with(csv_data)
  end

  it "passes the device id and the parsed data as json to the send to datastore job" do
    CSVUploadJob.perform_now(device_id, csv_data)
    expect(SendToDatastoreJob).to have_received(:perform_now).with(parsed_json, device_id)
  end
end
