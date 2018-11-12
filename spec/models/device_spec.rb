require 'rails_helper'

RSpec.describe Device, :type => :model do

  let(:mac_address) { "10:9a:dd:63:c0:10" }
  let(:device) { create(:device, mac_address: mac_address) }

  it { is_expected.to belong_to(:kit) }
  it { is_expected.to belong_to(:owner) }
  it { is_expected.to have_many(:devices_tags) }
  it { is_expected.to have_many(:tags).through(:devices_tags) }
  it { is_expected.to have_many(:components) }
  it { is_expected.to have_many(:sensors).through(:components) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:owner) }
  skip { is_expected.to validate_uniqueness_of(:name).scoped_to(:owner_id) }
  it { is_expected.to validate_uniqueness_of(:device_token) }

  it "has last_reading_at" do
    Timecop.freeze do
      device = create(:device, last_recorded_at: 1.minute.ago)
      expect(device.last_reading_at).to eq(1.minute.ago)
    end
  end

  it "has added_at"do
    Timecop.freeze do
      expect(create(:device).added_at).to eq(Time.current.utc)
    end
  end

  it "validates format of mac address, but allows nil" do
    expect{ create(:device, mac_address: '10:9A:DD:63:C0:10') }.to_not raise_error
    expect{ create(:device, mac_address: nil) }.to_not raise_error
    expect{ create(:device, mac_address: 123) }.to raise_error#(ActiveRecord::RecordInvalid)
  end

  describe "mac_address" do

    it "takes mac_address from existing device on update" do
      device = FactoryBot.create(:device, mac_address: mac_address)
      new_device = FactoryBot.create(:device)
      new_device.update_attribute(:mac_address, mac_address)
      expect(new_device.mac_address).to eq(mac_address)
      expect(new_device).to be_valid
      device.reload
      expect(device.mac_address).to be_blank
      # should be checking the following instead
      # expect(device).to receive(:remove_mac_address_for_newly_registered_device!)
    end

    it "takes mac_address from existing device on create" do
      device = FactoryBot.create(:device, mac_address: mac_address)
      new_device = FactoryBot.create(:device, mac_address: mac_address)
      expect(new_device.mac_address).to eq(mac_address)
      expect(new_device).to be_valid
      device.reload
      expect(device.mac_address).to be_blank
    end

    it "has remove_mac_address_for_newly_registered_device!" do
      device = create(:device, mac_address: mac_address, old_mac_address: nil)
      device.remove_mac_address_for_newly_registered_device!
      expect(device.mac_address).to be_blank
      expect(device.old_mac_address).to eq(mac_address)
    end

    it "can find device with upper or lowercase mac_address" do
      expect(Device.where(mac_address: mac_address.upcase )).to eq([device])
      expect(Device.where(mac_address: mac_address.downcase )).to eq([device])
    end

  end

  describe "states" do

    it "is not_configured by default" do
      device = create(:device, mac_address: nil)
      expect(device.state).to eq('not_configured')
    end

    it "is never_published if it has a mac_address and no data" do
      device = create(:device, mac_address: '5e:1d:41:62:76:d8', data: nil)
      expect(device.state).to eq('never_published')
    end

    it "is has_published if it has data and a mac_address" do
      device = create(:device, data: {a: 'b'}, mac_address: '5e:1d:41:62:76:d8')
      expect(device.state).to eq('has_published')
    end

    it "is has_published if it has data and NO mac_address" do
      device = create(:device, data: {a: 'b'}, mac_address: nil)
      expect(device.state).to eq('has_published')
    end

  end

  describe "workflow state" do

    it "only returns active devices by default (default_scope)" do
      a = create(:device)
      b = create(:device, workflow_state: :archived)
      expect(Device.all).to eq([a])
    end

    it "has a default active state" do
      expect(device.workflow_state).to eq('active')
    end

    it "can be archived" do
      device = create(:device, mac_address: mac_address)
      expect(device.old_mac_address).to be_blank
      device.archive!
      device.reload
      expect(device.workflow_state).to eq('archived')
      expect(device.mac_address).to be_blank
      puts device.old_mac_address
      expect(device.old_mac_address).to eq(mac_address)
    end

    it "can be unarchived from archive state" do
      device = create(:device, mac_address: mac_address)
      device.archive!
      device.unarchive!
      device.reload
      expect(device.workflow_state).to eq('active')
    end

    it "reassigns old_mac_address when unarchived" do
      device = create(:device, mac_address: mac_address)
      device.archive!
      device.unarchive!
      device.reload
      expect(device.mac_address).to eq('10:9a:dd:63:c0:10')
    end

    it "doesn't reassign old_mac_address if another device exists with that mac address" do
      device = create(:device, mac_address: mac_address)
      device.archive!
      device2 = create(:device, mac_address: mac_address)
      device.unarchive!
      device.reload
      expect(device.mac_address).to be_blank
    end

  end

  skip "includes owner in default_scope"

  describe "searching" do
    it "is (multi)searchable" do
      device = create(:device,
        name: 'awesome',
        description: 'amazing',
        city: 'paris',
        country_code: 'FR',
        latitude: nil,
        longitude: nil
      )

      expect(PgSearch.multisearch('test')).to be_empty
      %w(awesome Amazing PARis France).each do |search_term|
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
      expect(berlin.country.to_s).to eq("Germany")
      expect(berlin.country_name).to eq("Germany")
      expect(berlin.country_code).to eq("DE")
    end

    it "reverse geocodes on update" do
      berlin = create(:device, latitude: 52.4850463, longitude: 13.489651)
      berlin.update_attributes(latitude: 48.8582606, longitude: 2.2923184)
      expect(berlin.city).to eq("Paris")
      expect(berlin.country.to_s).to eq("France")
      expect(berlin.country_name).to eq("France")
      expect(berlin.country_code).to eq("FR")
    end

    it "calculates geohash on save" do
      barcelona = create(:device)
      expect(barcelona.geohash).to match('sp3e9bh31y')
    end

    it "calculates elevation on save", :vcr do
      barcelona = create(:device, elevation: nil)
      expect(barcelona.elevation).to eq(17)
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

    let(:kit) { build(:kit) }
    let(:sensor) { build(:sensor) }
    let(:device) { build(:device, kit: kit) }

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

    let(:sensor) { build(:sensor) }
    let(:device) { create(:device) }

    before(:each) do
      DatabaseCleaner.clean_with(:truncation) # We were getting ActiveRecord::RecordNotUnique:
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

  describe "device_token" do
    it 'validates uniqueness' do
      dev1 = create(:device, device_token: '123123')
      dev2 = build(:device, device_token: dev1.device_token)

      expect(dev2.save).to eq(false)
      expect(dev2.errors.messages[:device_token][0]).to eq('has already been taken')
    end

    it 'does not validate uniqueness when nil' do
      dev1 = create(:device)
      dev2 = build(:device)

      expect(dev2.save).to eq(true)
      expect(dev2.errors.messages[:device_token].nil?).to eq(true)
    end
  end
end
