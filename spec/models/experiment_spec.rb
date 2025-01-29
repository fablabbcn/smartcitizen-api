require "rails_helper"

RSpec.describe Experiment, type: :model do
  describe "validations" do
    describe "validate date format" do
      describe "start date" do
        it "is valid with a full iso datetime string" do
          experiment = build(:experiment, starts_at: "2024-01-02T06:00:00Z")
          expect(experiment).to be_valid
        end

        it "is valid with a date only iso datetime string" do
          experiment = build(:experiment, starts_at: "2024-01-02")
          expect(experiment).to be_valid
        end

        it "is invalid with an invalid datetime" do
          experiment = build(:experiment, starts_at: "lolwut")
          expect(experiment).not_to be_valid
        end
      end

      describe "end date" do
        it "is valid with a full iso datetime string" do
          experiment = build(:experiment, ends_at: "2024-01-02T06:00:00Z")
          expect(experiment).to be_valid
        end

        it "is valid with a date only iso datetime string" do
          experiment = build(:experiment, ends_at: "2024-01-02")
          expect(experiment).to be_valid
        end

        it "is invalid with an invalid datetime" do
          experiment = build(:experiment, ends_at: "lolwut")
          expect(experiment).not_to be_valid
        end
      end
    end

    describe "start date is before end date" do
      it "is invalid when end date is before start date" do
        experiment = build(:experiment, starts_at: "2024-02-01", ends_at: "2024-01-01")
        expect(experiment).not_to be_valid
      end

      it "is valid when start date is before end date" do
        experiment = build(:experiment, starts_at: "2024-01-01", ends_at: "2024-02-01")
        expect(experiment).to be_valid
      end

      it "is valid with only a start date" do
        experiment = build(:experiment, starts_at: "2024-01-01")
        expect(experiment).to be_valid
      end

      it "is valid with only an end date" do
        experiment = build(:experiment, ends_at: "2024-01-01")
        expect(experiment).to be_valid
      end
    end


    describe "device privacy" do
      context "when the experiment has private devices owned by the same owner" do
        it "is valid" do
          owner = create(:user)
          device = create(:device, is_private: true, owner: owner)
          experiment = build(:experiment, owner: owner, devices: [device])
          expect(experiment).to be_valid
        end
      end

      context "when the experiment has public devices owned by another user" do
        it "is valid" do
          device_owner = create(:user)
          experiment_owner = create(:user)
          device = create(:device, is_private: false, owner: device_owner)
          experiment = build(:experiment, owner: experiment_owner, devices: [device])
          expect(experiment).to be_valid
        end
      end

      context "when the experiment has private devices owned by another user" do
        it "is not valid" do
          device_owner = create(:user)
          experiment_owner = create(:user)
          device = create(:device, is_private: true, owner: device_owner)
          experiment = build(:experiment, owner: experiment_owner, devices: [device])
          expect(experiment).not_to be_valid
        end
      end
    end
  end

  describe "#is_active?" do
    context "when the experiment has neither start or end times" do
      it "is active" do
        experiment = build(:experiment, starts_at: nil, ends_at: nil)
        expect(experiment).to be_active
      end
    end

    context "when the experiment has a start time but no end time" do
      it "is inactive before the start time" do
        experiment = build(:experiment, starts_at: Time.now + 1.hour, ends_at: nil)
        expect(experiment).not_to be_active
      end

      it "is active after the start time" do
        experiment = build(:experiment, starts_at: Time.now - 1.hour, ends_at: nil)
        expect(experiment).to be_active
      end
    end

    context "when the experiment has an end time but no start time" do
      it "is active before the end time" do
        experiment = build(:experiment, starts_at: nil, ends_at: Time.now + 1.hour)
        expect(experiment).to be_active
      end

      it "is inactive after the end time" do
        experiment = build(:experiment, starts_at: nil, ends_at: Time.now - 1.hour)
        expect(experiment).not_to be_active
      end
    end

    context "when the experiment has both start and end times" do
      it "is inactive before the start time" do
        experiment = build(:experiment, starts_at: Time.now + 1.hour, ends_at: Time.now + 2.hours)
        expect(experiment).not_to be_active
      end

      it "is active between the start and end times" do
        experiment = build(:experiment, starts_at: Time.now - 1.hour, ends_at: Time.now + 1.hour)
        expect(experiment).to be_active
      end

      it "is inactive after the end time" do
        experiment = build(:experiment, starts_at: Time.now - 2.hours, ends_at: Time.now - 1.hour)
        expect(experiment).not_to be_active
      end
    end
  end

  describe "last_reading_at" do
    it "returns the latest reading of all the devices" do
      time = Time.now - 5.minutes
      experiment = build(:experiment, devices: [
        build(:device, last_reading_at: time - 1.hour),
        build(:device, last_reading_at: time),
        build(:device, last_reading_at: nil),
        build(:device, last_reading_at: time - 30.minutes)
      ])
      expect(experiment.last_reading_at).to eq(time)
    end
  end

  describe "all_tags" do
    it "returns a unique list of all device tags, without nils" do
      device_1 = build(:device)
      device_2 = build(:device)
      expect(device_1).to receive(:all_tags).and_return(["indoor", "test"])
      expect(device_2).to receive(:all_tags).and_return(["indoor", "third_floor", nil])
      experiment = create(:experiment, devices: [device_1, device_2])
      expect(experiment.all_tags).to eq(["indoor", "test", "third_floor"])
    end
  end

  describe "all_measurements" do
    it "returns a unique list of all measurements for non-raw sensors of all devices" do
      measurement_1 = create(:measurement)
      sensor_1 = create(:sensor, measurement: measurement_1)

      measurement_2 = create(:measurement)
      sensor_2 = create(:sensor, measurement: measurement_2)

      measurement_3 = create(:measurement)
      sensor_3 = create(:sensor, measurement: measurement_3)

      raw_measurement = create(:measurement)
      raw_sensor = create(:sensor, measurement: raw_measurement, tag_sensors: [build(:tag_sensor, name: "raw" )])

      device_1 = create(:device, components: [
        create(:component, sensor: sensor_1),
        create(:component, sensor: sensor_2)
      ])

      device_2 = create(:device, components: [
        create(:component, sensor: sensor_2),
        create(:component, sensor: sensor_3),
        create(:component, sensor: raw_sensor)
      ])

      experiment = create(:experiment, devices: [device_1, device_2])

      expect(experiment.all_measurements).to eq(
        [measurement_1, measurement_2, measurement_3]
      )
    end
  end

  describe "components_for_measurement" do
    it "returns all non-raw components for the given measurement" do

      measurement_1 = create(:measurement)
      sensor_1 = create(:sensor, measurement: measurement_1)

      measurement_2 = create(:measurement)
      sensor_2 = create(:sensor, measurement: measurement_2)
      sensor_3 = create(:sensor,
        measurement: measurement_2,
        tag_sensors: [build(:tag_sensor, name: "raw")]
      )

      component_1 = create(:component, sensor: sensor_1)
      component_2 = create(:component, sensor: sensor_2)
      device_1 = create(:device, components: [component_1, component_2])

      component_3 = create(:component, sensor: sensor_3)
      component_4 = create(:component, sensor: sensor_2)
      device_2 = create(:device, components: [component_3, component_4])

      component_5 = create(:component, sensor: sensor_3)
      device_3 = create(:device, components: [component_5])


      experiment = create(:experiment, devices: [device_1, device_2, device_3])

      expect(experiment.components_for_measurement(measurement_2)).to eq(
        [component_2, component_4]
      )
    end
  end
end
