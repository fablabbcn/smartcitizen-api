require 'rails_helper'

RSpec.describe Device, :type => :model do

  let(:device) { create(:device) }

  it { is_expected.to belong_to(:kit) }
  it { is_expected.to belong_to(:owner) }
  it { is_expected.to have_many(:devices_tags) }
  it { is_expected.to have_many(:tags).through(:devices_tags) }
  it { is_expected.to have_many(:components) }
  it { is_expected.to have_many(:sensors).through(:components) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:owner) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:owner_id) }

  it "does not allow banned names" do
    puts Smartcitizen::Application.config.banned_words
    device = build(:device, name: "stupid")
    device.valid?
    expect(device.errors[:name]).to include('is reserved')
  end

  it "validates format of mac address" do
    expect{ create(:device, mac_address: '10:9A:DD:63:C0:10') }.to_not raise_error
    expect{ create(:device, mac_address: 123) }.to raise_error#(ActiveRecord::RecordInvalid)
  end

  it "validates uniqueness of mac address on create" do
    create(:device, mac_address: '10:9A:DD:63:C0:10', owner: create(:user))
    expect{ create(:device, mac_address: '10:9A:DD:63:C0:10') }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "validates uniqueness of mac address on update" do
    d1 = create(:device, mac_address: '10:9A:DD:63:C0:10')
    d2 = create(:device, mac_address: '10:9A:DD:63:C0:11')
    d2.mac_address = '10:9A:DD:63:C0:10'
    expect(d2).to be_invalid
  end

  describe "states" do
    it "has a default active state" do
      expect(device.workflow_state).to eq('active')
    end

    it "can be archived" do
      device.archive!
      expect(device.workflow_state).to eq('archived')
    end

    it "can be activated from archive state" do
      device.archive!
      device.activate!
      expect(device.workflow_state).to eq('active')
    end

    it "only returns active devices by default (default_scope)" do
      a = create(:device)
      b = create(:device, workflow_state: :archived)
      expect(Device.all).to eq([a])
    end

  end

  skip "includes owner in default_scope"

  describe "searching" do
    it "is (multi)searchable" do
      device = create(:device,
        name: 'awesome',
        description: 'amazing',
        city: 'paris',
        country_code: 'FR'
      )
      expect(PgSearch.multisearch('test')).to be_empty
      %w(awesome amazing paris France).each do |search_term|
        result = PgSearch.multisearch(search_term)
        expect(result.length).to eq(1)
        expect(result.first.searchable_id).to eq(device.id)
        expect(result.first.searchable_type).to eq('Device')
      end
    end

  end

  describe "geocoding" do
    it "reverse geocodes on create" do
      berlin = create(:device, latitude: 52.4850463, longitude: 13.489651)
      expect(berlin.city).to eq("Berlin")
      expect(berlin.country).to eq("Germany")
      expect(berlin.country_code).to eq("DE")
    end

    it "calculates geohash on save" do
      barcelona = create(:device)
      expect(barcelona.geohash).to match('sp3e9bh31y')
    end

    it "calculates elevation on save", :vcr do
      barcelona = create(:device, elevation: nil)
      expect(barcelona.elevation).to eq(4)
    end

  end

  describe "kit_version" do
    it "has kit_version setter" do
      device = build(:device, kit_version: "1.1")
      expect(device.kit_id).to eq(3)

      device = build(:device, kit_version: "1.0")
      expect(device.kit_id).to eq(2)
    end

    it "has kit_version getter" do
      device = build(:device, kit_id: 3)
      expect(device.kit_version).to eq("1.1")

      device = build(:device, kit_id: 2)
      expect(device.kit_version).to eq("1.0")
    end
  end

  it "has to_s" do
    device = create(:device, name: 'cool device')
    expect(device.to_s).to eq('cool device')
  end

  skip "has all_readings, in latest first order" do
    reading1 = create(:reading, device_id: device.id, recorded_at: Time.current.utc - 1)
    reading2 = create(:reading, device_id: device.id, recorded_at: Time.current.utc)
    expect(device.all_readings.map{|a| a.recorded_at.to_i}).to eq([reading2.recorded_at.to_i, reading1.recorded_at.to_i])
  end

  skip "has status" do
    expect(Device.new.status).to eq('new')
    expect(create(:device, last_recorded_at: 1.minute.ago).status).to eq('online')
    expect(create(:device, last_recorded_at: 10.minutes.ago).status).to eq('offline')
  end

  it "has firmware" do
    expect(create(:device, firmware_version: 'xyz').firmware).to eq('sck:xyz')
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
    barcelona = create(:device)
    paris = create(:device, latitude: 48.8582606, longitude: 2.2923184)
    old_trafford = create(:device, latitude: 53.4630589, longitude: -2.2935288)

    london_coordinates = [51.503324,-0.1217317]

    expect(Device.near(london_coordinates, 5000)).to eq([old_trafford, paris, barcelona])
  end

end
