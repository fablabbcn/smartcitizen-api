require 'rails_helper'

RSpec.describe Device, :type => :model do

  let(:mac_address) { "10:9a:dd:63:c0:10" }
  let(:device) { create(:device, mac_address: mac_address) }

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
      device = create(:device, last_reading_at: 1.minute.ago)
      expect(device.last_reading_at).to eq(1.minute.ago)
    end
  end

  it "validates format of mac address, but allows nil" do
    expect{ create(:device, mac_address: '10:9A:DD:63:C0:10') }.to_not raise_error
    expect{ create(:device, mac_address: nil) }.to_not raise_error
    expect{ create(:device, mac_address: 123) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  describe "#sensor_map" do
    it "maps the component key to the sensor id" do
      device = create(:device)
      sensor = create(:sensor, default_key: "sensor_key")
      component = create(:component, device: device, sensor: sensor, key: "component_key")
      expect(device.sensor_map).to eq({"component_key" => sensor.id})
    end
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
      berlin.update(latitude: 48.8582606, longitude: 2.2923184)
      expect(berlin.city).to eq("Paris")
      expect(berlin.country.to_s).to eq("France")
      expect(berlin.country_name).to eq("France")
      expect(berlin.country_code).to eq("FR")
    end

    it "calculates geohash on save" do
      barcelona = create(:device)
      expect(barcelona.geohash).to match(/^sp3e/)
    end

    skip "calculates elevation on save", :vcr do
      # not calculating elevation anymore
      barcelona = create(:device, elevation: nil)
      expect(barcelona.elevation).to eq(17)
    end

  end

  describe "location truncation and fuzzing" do

    context "by default" do
      it "saves the precise location" do
        device = create(:device, latitude: 0.12345, longitude: 10.12345)
        expect(device.precise_location).to eq(true)
        expect(device.latitude).to eq(0.12345)
        expect(device.longitude).to eq(10.12345)
      end
    end

    context "when the location is changed" do
      context "when the device has precise location set" do
        let(:device) {
          create(:device, precise_location: true)

        }

        it "truncates the location to 5 decimal places" do
          device.update(latitude: 0.1234567, longitude: 10.1234567)
          device.save
          expect(device.latitude).to eq(0.12345)
          expect(device.longitude).to eq(10.12345)
        end
      end

      context "when the device has no precise location set" do
        let(:device) {
          create(:device, precise_location: false)

        }


        it "truncates the location to 3 decimal places and adds 2 extra dp of randomness" do
          device.update(latitude: 0.12345, longitude: 10.12345)
          device.save
          expect(device.latitude).not_to eq(0.12345)
          expect(device.longitude).not_to eq(10.12345)
          expect((device.latitude - 0.12345).abs.truncate(5)).to be <= 0.001
          expect((device.longitude - 10.12345).abs.truncate(5)).to be <= 0.001
        end
      end
    end

    context "when the location is not changed" do
      let(:device) {
        create(:device, precise_location: false, latitude: 0.12345, longitude: 0.12345)

      }

      it "does not re-fuzz the device location" do
        lat_before = device.latitude
        long_before = device.longitude

        device.update(name: "not updating location")
        device.save!

        expect(device.reload.latitude).to eq(lat_before)
        expect(device.reload.longitude).to eq(long_before)
      end
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
    expect(create(:device, last_reading_at: 1.minute.ago).status).to eq('online')
    expect(create(:device, last_reading_at: 10.minutes.ago).status).to eq('offline')
  end

  it "has firmware" do
    expect(create(:device, firmware_version: 'xyz').firmware).to eq('sck:xyz')
  end

  context "creation" do

    let(:sensor) { create(:sensor) }
    let(:device) { create(:device, sensors: [sensor]) }

    it "has its own sensors" do
      expect(device.sensors).to eq([sensor])
    end

    it "has its own components" do
      expect(device.components).to eq([Component.find_by(device: device, sensor: sensor)])
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

    it 'can be ransacked if admin' do
      # Ransacking
      create(:device, device_token: '123123')
      create(:device, device_token: '999999')
      create(:device, device_token: '000000')
      expect(Device.count).to eq(3)
      # Admins can ransack on device_token_contains
      expect(Device.ransack({device_token_cont: '123'}, auth_object: :admin).result.count).to eq(1)
      # Normal users cannot ransack on device_token
      expect {
        Device.ransack({device_token_cont: '123'})
      }.to raise_error(ArgumentError)
    end

    it 'does not validate uniqueness when nil' do
      dev1 = create(:device)
      dev2 = build(:device)

      expect(dev2.save).to eq(true)
      # FIXME broke after Rails 4 -> 5 update
      #expect(dev2.errors.messages[:device_token].nil?).to eq(true)
    end
  end

  describe "update_column_timestamps" do

    before do
      @device = create(:device)
      @component_1 = create(:component, device: @device, sensor: create(:sensor, id: 1), updated_at: "2023-01-01 12:00:00")
      @component_2 = create(:component, device: @device,  sensor: create(:sensor, id: 2))
      @device.reload
      @timestamp = Time.parse("2023-10-06 06:00:00")
    end

    it "updates the timestamp for components with the given sensor ids" do
      @device.update_component_timestamps(@timestamp, [1])
      expect(@component_1.reload.last_reading_at).to eq(@timestamp)
    end

    it "does not update the timesatamp for components without the given sensor ids" do
      expect(@component_2).not_to receive(:update).with(last_reading_at: @timestamp)
      @device.update_component_timestamps(@timestamp, [1])
    end

    it "does not update the component updated_at" do
      updated_at = @component_1.updated_at
      @device.update_component_timestamps(@timestamp, [1])
      expect(@component_1.reload.updated_at).to eq(updated_at)
    end
  end

  context "notifications for low battery" do
    describe "do not get sent" do
      it 'when they are disabled' do
        device = create(:device, notify_low_battery: false)
        expect(device).to have_attributes(notify_low_battery: false)
        before_date = device.notify_low_battery_timestamp
        CheckBatteryLevelBelowJob.perform_now
        # Make sure timestamp is NOT updated after running job
        device.reload
        expect(before_date).to eq device.notify_low_battery_timestamp
      end

      describe 'when enabled, but' do
        it 'timestamp is too recent' do
          device = create(:device, notify_low_battery: true, notify_low_battery_timestamp: 45.minutes.ago, data: { 10 => 3 } )
          device.reload
          before_date = device.notify_low_battery_timestamp
          expect(device).to have_attributes(notify_low_battery: true)
          expect(device.notify_low_battery_timestamp).to be < (30.minutes.ago)
          CheckBatteryLevelBelowJob.perform_now
          device.reload
          expect(before_date).to eq device.notify_low_battery_timestamp
        end

        it 'battery is charging' do
          device = create(:device, notify_low_battery: true, notify_low_battery_timestamp: 5.days.ago, data: { 10 => -1 } )
          expect(device.notify_low_battery_timestamp).to be < (3.days.ago)
          device.reload
          before_date = device.notify_low_battery_timestamp
          CheckBatteryLevelBelowJob.perform_now
          device.reload
          expect(before_date).to eq device.notify_low_battery_timestamp
        end

        it 'battery is full' do
          device = create(:device, notify_low_battery: true, notify_low_battery_timestamp: 5.days.ago, data: { 10 => 99 } )
          expect(device.notify_low_battery_timestamp).to be < (3.days.ago)
          device.reload
          before_date = device.notify_low_battery_timestamp
          CheckBatteryLevelBelowJob.perform_now
          device.reload
          expect(before_date).to eq device.notify_low_battery_timestamp
        end
      end
    end

    describe "do get sent" do
      it 'only when enabled, battery is low AND timestamp is more than 12 hours old' do
        device = create(:device, notify_low_battery: true, notify_low_battery_timestamp: 2.day.ago, data:{ 10 => 3 } )
        before_date = device.notify_low_battery_timestamp
        expect(device).to have_attributes(notify_low_battery: true)
        expect(device.notify_low_battery_timestamp).to be < (12.hours.ago)
        expect(device.data["10"]).to be < (15)
        CheckBatteryLevelBelowJob.perform_now
        # Make sure timestamp was updated
        device.reload
        expect(before_date).to be < device.notify_low_battery_timestamp
      end
    end
  end

  context "notifications for stopped publishing" do
    describe "do not get sent" do
      it 'when they are disabled' do
        device = create(:device, notify_stopped_publishing: false, last_reading_at: 24.hours.ago)
        expect(device).to have_attributes(notify_stopped_publishing: false)
        before_date = device.notify_stopped_publishing_timestamp
        CheckDeviceStoppedPublishingJob.perform_now
        # Make sure timestamp is NOT updated after running job
        device.reload
        expect(before_date).to eq device.notify_stopped_publishing_timestamp
      end

      it 'when they are enabled, but timestamp is too recent' do
        device = create(:device, notify_stopped_publishing: true,
                        last_reading_at: 2.hours.ago,
                        notify_stopped_publishing_timestamp: 2.hours.ago)
        device.reload
        expect(device).to have_attributes(notify_stopped_publishing: true)
        expect(device.notify_stopped_publishing_timestamp).to be < (1.hours.ago)
        before_date = device.notify_stopped_publishing_timestamp
        CheckDeviceStoppedPublishingJob.perform_now
        # Make sure timestamp is NOT updated after running job
        device.reload
        expect(before_date).to eq device.notify_stopped_publishing_timestamp
       end
    end

    describe "do get sent" do
       it 'when enabled, timestamp is more than 24 hours old AND last_reading older than 10 minutes' do
        device = create(:device, notify_stopped_publishing: true,
                        last_reading_at: 2.hours.ago,
                        notify_stopped_publishing_timestamp: 25.hours.ago)
        device.reload
        expect(device).to have_attributes(notify_stopped_publishing: true)
        expect(device.notify_stopped_publishing_timestamp).to be < (20.hours.ago)
        before_date = device.notify_stopped_publishing_timestamp
        CheckDeviceStoppedPublishingJob.perform_now
        # Make sure timestamp is WAS updated after running job
        device.reload
        expect(before_date).to be < device.notify_stopped_publishing_timestamp
      end
    end
  end

  context "deletion" do
    it "deletes the associated postprocessing info" do
      device = create(:device)
      device.create_postprocessing!
      expect {
        device.destroy!
      }.not_to raise_error
      expect(Postprocessing.count).to eq(0)
      expect(Device.count).to eq(0)
    end
  end

  describe "hardware info" do
    describe "hardware_name" do
      context "when it has a name override" do
        it "returns the overriden name" do
          device = create(:device, hardware_name_override: "Overriden name")
          expect(device.hardware_name).to eq("Overriden name")
        end
      end

      context "when it has a hardware_version" do
        it "returns the string 'SmartCitizen Kit' concatenated with the version" do
          device = create(:device)
          expect(device).to receive(:hardware_version).at_least(:once).and_return("1.0.0")
          expect(device.hardware_name).to eq("SmartCitizen Kit 1.0.0")
        end
      end

      context "otherwise" do
        it "returns the string 'Unknown'" do
          device = create(:device)
          expect(device.hardware_name).to eq("Unknown")
        end
      end
    end

    describe "hardware_type" do
      context "when it has a type override" do
        it "returns the overriden type" do
          device = create(:device, hardware_type_override: "Overriden type")
          expect(device.hardware_type).to eq("Overriden type")
        end
      end

      context "when it has a hardware_version" do
        it "returns the string 'SCK'" do
          expect(device).to receive(:hardware_version).and_return("1.0.0")
          expect(device.hardware_type).to eq("SCK")
        end
      end

      context "otherwise" do
        it "returns the string 'Unknown'" do
          device = create(:device)
          expect(device.hardware_type).to eq("Unknown")
        end
      end
    end

    describe "hardware_version" do
      context "when it has a version override" do
        it "returns the overriden version" do
          device = create(:device, hardware_version_override: "1.4.0+with+extra+sensors")
          expect(device.hardware_version).to eq("1.4.0+with+extra+sensors")
        end
      end

      context "when it has hardware_info" do
        it "returns the version from hardware_info" do
          device = create(:device, hardware_info: { hw_ver: "1.5.0" })
          expect(device.hardware_version).to eq("1.5.0")
        end
      end

      context "otherwise" do
        it "returns nil" do
          device = create(:device)
          expect(device.hardware_version).to be(nil)
        end
      end
    end

    describe "hardware_slug" do
      context "when it has a slug override" do
        it "returns the overriden slug" do
          device = create(:device, hardware_slug_override: "overriden_slug")
          expect(device.hardware_slug).to eq("overriden_slug")
        end
      end

      context "when it has a hardware_version" do
        it "returns the hardware type downcased, concatenated with the version number with periods translated to commas, seperated by a colon" do
          device = create(:device)
          expect(device).to receive(:hardware_type).and_return("SCK")
          expect(device).to receive(:hardware_version).and_return("1.0.0")
          expect(device.hardware_slug).to eq("sck:1,0,0")
        end
      end

      context "when it has no harware version" do
        it "returns the hardware type downcased" do
          device = create(:device)
          expect(device.hardware_slug).to eq("unknown")
        end
      end
    end
  end

  describe "forwarding" do
    describe "#forward_readings?" do
      context "when the device has forwarding enabled" do
        let(:device) {
          create(:device, enable_forwarding: true)
        }

        context "when forward_device_readings is true on the owning user" do
          it "forwardds readings" do
            expect(device.owner).to receive(:forward_device_readings?).and_return(true)
            expect(device.forward_readings?).to be(true)
          end
        end

        context "when forward_device_readings is not true on the owning user" do
          it "does not forward readings" do
            expect(device.owner).to receive(:forward_device_readings?).and_return(false)
            expect(device.forward_readings?).to be(false)
          end
        end
      end

      context "when the device does not have forwarding enabled" do
        let(:device) {
          create(:device, enable_forwarding: false)
        }

        context "when forward_device_readings is true on the owning user" do
          it "does not forward readings" do
            allow(device.owner).to receive(:forward_device_readings?).and_return(true)
            expect(device.forward_readings?).to be(false)
            expect(device.owner).not_to have_received(:forward_device_readings?)
          end
        end

        context "when forward_device_readings is not true on the owning user" do
          it "does not forward readings" do
            allow(device.owner).to receive(:forward_device_readings?).and_return(false)
            expect(device.forward_readings?).to be(false)
            expect(device.owner).not_to have_received(:forward_device_readings?)
          end
        end


      end

      it "delegates to the forward_device_readings? method on the device owner" do
      end
    end

    describe "#forwarding_token?" do
      it "delegates to the device owner" do
        forwarding_token = double(:forwarding_token)
        expect(device.owner).to receive(:forwarding_token).and_return(forwarding_token)
        expect(device.forwarding_token).to eq(forwarding_token)
      end
    end
  end

  describe "#create_or_find_component_by_sensor_id" do
    context "when the sensor exists and a component already exists for this device" do
      it "returns the existing component" do
        sensor = create(:sensor)
        component = create(:component, sensor: sensor, device: device)
        expect(device.create_or_find_component_by_sensor_id(sensor.id)).to eq(component)
      end
    end

    context "when the sensor exists and a component does not already exist for this device" do
      it "returns a new valid component with the correct sensor and device" do
        sensor = create(:sensor)
        component = device.create_or_find_component_by_sensor_id(sensor.id)
        expect(component).not_to be_blank
        expect(component).to be_a Component
        expect(component.valid?).to be(true)
        expect(component.persisted?).to be(true)
        expect(component.device).to eq(device)
        expect(component.sensor).to eq(sensor)
      end
    end

    context "when no sensor exists with this id" do
      it "returns nil" do
        create(:sensor, id: 12345)
        expect(device.create_or_find_component_by_sensor_id(54321)).to be_blank
      end
    end

    context "when the id is nil" do
      it "returns nil" do
        expect(device.create_or_find_component_by_sensor_id(nil)).to be_blank
      end
    end
  end

  context ".for_world_map" do

    let(:current_user) { create(:user) }
    let(:other_user)  { create(:user) }
    let(:admin) { create(:admin) }

    let(:public_device) { create(:device, last_reading_at: Time.now) }
    let(:my_private_device) { create(:device, is_private: true, owner: current_user, last_reading_at: Time.now) }
    let(:their_private_device) { create(:device, is_private: true, owner: other_user, last_reading_at: Time.now) }


    context "when no authorized user is provided" do
      it "only returns public devices" do
        results = Device.for_world_map(false)
        expect(results).to include(public_device)
        expect(results).not_to include(my_private_device)
        expect(results).not_to include(their_private_device)
      end
    end

    context "when a non-admin user is provided" do
      it "only returns public devices, and private devices owned by the current user" do
        results = Device.for_world_map(current_user)
        expect(results).to include(public_device)
        expect(results).to include(my_private_device)
        expect(results).not_to include(their_private_device)
      end
    end

    context "when an admin user is provided" do
      it "returns all devices" do
        results = Device.for_world_map(admin)
        expect(results).to include(public_device)
        expect(results).to include(my_private_device)
        expect(results).to include(their_private_device)
      end
    end
  end

end
