require 'rails_helper'

RSpec.describe Device, :type => :model do

  it { is_expected.to belong_to(:owner) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:owner) }
  it { is_expected.to validate_presence_of(:mac_address) }

  let(:device) { create(:device) }

  it "validates format of mac address" do
    expect{ create(:device, mac_address: '10:9A:DD:63:C0:10') }.to_not raise_error
    expect{ create(:device, mac_address: 123) }.to raise_error
  end

  it "validates uniqueness of mac address" do
    create(:device, mac_address: '10:9A:DD:63:C0:10')
    expect{ create(:device, mac_address: '10:9A:DD:63:C0:10') }.to raise_error
  end

  it "has all_readings, in latest first order" do
    reading1 = Reading.create!(device_id: device.id, recorded_at: Time.now - 1, raw_data: {a: 'b'})
    reading2 = Reading.create!(device_id: device.id, recorded_at: Time.now, raw_data: {a: 'b'})
    expect(device.all_readings.map{|a| a.recorded_at.to_i}).to eq([reading2.recorded_at.to_i, reading1.recorded_at.to_i])
  end

  context "with kit" do

    let(:kit) { create(:kit) }
    let(:sensor) { create(:sensor) }
    let(:device) { create(:device, kit: kit) }

    before(:each) do
      kit.sensors << sensor
    end

    it "has the kit's sensors" do
      expect(device.sensors).to eq(kit.sensors)
    end

    it "has the kit's components" do
      expect(device.components).to eq(kit.components)
    end

  end

  context "without kit" do

    let(:sensor) { create(:sensor) }
    let(:device) { create(:device) }

    before(:each) do
      device.sensors << sensor
    end

    it "has its own sensors" do
      expect(device.sensors).to eq([sensor])
    end

    it "has its own components" do
      expect(device.components).to eq([Component.find_by(board: device, sensor: sensor)])
    end
  end

  it "can sort by distance" do
    barcelona = create(:device, latitude: 41.39479, longitude: 2.1487679)
    paris = create(:device, latitude: 48.8588589, longitude: 2.3470599)
    manchester = create(:device, latitude: 53.4722454, longitude: -2.2235922)

    london_coordiantes = [51.5286416,-0.1015987]

    expect(Device.near(london_coordiantes, 5000)).to eq([manchester, paris, barcelona])
  end

  it "calculates geohash on save" do
    berlin = create(:device, latitude: 52.5075419, longitude: 13.4251364)
    expect(berlin.geohash).to match('u33d9qxy')
  end

end
