require 'rails_helper'

RSpec.describe Reading, :type => :model do

  let(:device) { create(:device) }

  it { is_expected.to validate_presence_of(:device_id) }

  describe "recorded_at" do
    it { is_expected.to validate_presence_of(:recorded_at) }

    it "is within the last year" do
      expect{create(:reading, recorded_at: 13.months.ago)}.to raise_error(Cequel::Record::RecordInvalid)
      expect(create(:reading, recorded_at: 11.months.ago)).to be_valid
    end

    it "is before tomorrow" do
      expect(create(:reading, recorded_at: 23.hours.from_now)).to be_valid
      expect{create(:reading, recorded_at: 24.hours.from_now)}.to raise_error(Cequel::Record::RecordInvalid)
    end

    it "generates recorded_month on create" do
      expect(create(:reading, recorded_at: "05/02/2015 19:30:00").recorded_month).to eq(201502)
    end
  end

  describe "create_from_api" do

    it "requires parameters" do
      expect{Reading.create_from_api()}.to raise_error(ArgumentError)
    end

    it "requires valid mac address" do
      expect{Reading.create_from_api('12:23:42', '1', '{a: "b"}', "127.0.0.1")}.to raise_error(ActiveRecord::StatementInvalid)
    end

    it "parses different timestamps" do
      expect(create(:reading, recorded_at: "05/02/2015 19:30:00").recorded_month).to eq(201502)
      expect(create(:reading, recorded_at: 1428736422).recorded_month).to eq(201504)
      # expect((:reading, recorded_at: '2nd Feb 2015')).to raise_error
    end

  end

  skip "id has device_id:recorded_at:created_at"

  it "belongs to device" do
    device = create(:device)
    reading = Reading.new(device_id: device.id)
    expect(reading.device).to eq(device)
  end

  describe "calibrate" do
    skip "updates latest_data on its device"
  end

end
