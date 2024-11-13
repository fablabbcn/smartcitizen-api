require "rails_helper"
describe Presenters::DevicePresenter do

  let(:owner) {
    FactoryBot.create(:user)
  }

  let(:components) {
    double(:components)
  }

  let(:device) {
    FactoryBot.create(:device, owner: owner).tap do |device|
      allow(device).to receive(:components).and_return(components)
    end
  }

  let(:current_user) {
    FactoryBot.create(:user)
  }

  let(:render_context) {
    double(:render_context)
  }

  let(:options) {
    { readings: readings }
  }

  let(:readings) {
    double(:readings)
  }

  let(:owner_presentation) {
    double(:owner_presentation)
  }

  let(:components_presentation) {
    double(:components_presentation)
  }

  let(:show_private_info) { false }

  let(:device_policy) {
    double(:device_policy).tap do |device_policy|
      allow(device_policy).to receive(:show_private_info?).and_return(show_private_info)
    end
  }


  before do
    allow(DevicePolicy).to receive(:new).and_return(device_policy)

    allow(Presenters).to receive(:present) do |model|
      case model
      when owner
        owner_presentation
      when components
        components_presentation
      end
    end
  end

  subject(:presenter) { Presenters::DevicePresenter.new(device, current_user, render_context, options) }

  it "exposes the id" do
    expect(presenter.as_json[:id]).to eq(device.id)
  end

  it "exposes the uuid" do
    expect(presenter.as_json[:uuid]).to eq(device.uuid)
  end

  it "exposes the name" do
    expect(presenter.as_json[:name]).to eq(device.name)
  end

  it "exposes the description" do
    expect(presenter.as_json[:description]).to eq(device.description)
  end

  it "exposes the state" do
    expect(presenter.as_json[:state]).to eq(device.state)
  end

  it "exposes the system_tags" do
    expect(presenter.as_json[:system_tags]).to eq(device.system_tags)
  end

  it "exposes the user_tags" do
    expect(presenter.as_json[:user_tags]).to eq(device.user_tags)
  end

  it "exposes the last_reading_at date" do
    expect(presenter.as_json[:last_reading_at]).to eq(device.last_reading_at)
  end

  it "exposes the created_at date" do
    expect(presenter.as_json[:created_at]).to eq(device.created_at)
  end

  it "exposes the updated_at date" do
    expect(presenter.as_json[:updated_at]).to eq(device.updated_at)
  end

  it "includes the notification statuses" do
    expect(presenter.as_json[:notify][:stopped_publishing]).to eq(device.notify_stopped_publishing)
    expect(presenter.as_json[:notify][:low_battery]).to eq(device.notify_low_battery)
  end

  it "includes public hardware info" do
    expect(presenter.as_json[:hardware][:name]).to eq(device.hardware_name)
    expect(presenter.as_json[:hardware][:type]).to eq(device.hardware_type)
    expect(presenter.as_json[:hardware][:version]).to eq(device.hardware_version)
    expect(presenter.as_json[:hardware][:slug]).to eq(device.hardware_slug)
  end

  context "by default" do
    it "includes the location information" do
      expect(presenter.as_json[:location][:exposure]).to eq(device.exposure)
      expect(presenter.as_json[:location][:elevation]).to eq(device.elevation&.to_i)
      expect(presenter.as_json[:location][:latitude]).to eq(device.latitude)
      expect(presenter.as_json[:location][:longitude]).to eq(device.longitude)
      expect(presenter.as_json[:location][:geohash]).to eq(device.geohash)
      expect(presenter.as_json[:location][:city]).to eq(device.city)
      expect(presenter.as_json[:location][:country]).to eq(device.country_name)
    end

    it "includes the postprocessing information" do
      expect(presenter.as_json[:postprocessing]).to eq(device.postprocessing)
    end

    it "includes a presentation of the owner, without associated devices" do
      expect(presenter.as_json[:owner]).to eq(owner_presentation)
      expect(Presenters).to have_received(:present).with(device.owner, current_user, render_context, with_devices: false)
    end

    it "includes a presentation of the components, passing the readings  as an option" do
      expect(presenter.as_json[:components]).to eq(components_presentation)
      expect(Presenters).to have_received(:present).with(device.components, current_user, render_context, readings: readings)
    end
  end

  context "when with_location is false" do
    let(:options) { { with_location: false } }
    it "does not include the location information" do
      expect(presenter.as_json[:location]).to be(nil)
    end
  end


  context "when with_postprocessing is false" do
    let(:options) { { with_postprocessing: false } }
    it "does not include the postprocessing information" do
      expect(presenter.as_json[:postprocessing]).to be(nil)
    end
  end

  context "when with_owner is false" do
    let(:options) { { with_owner: false } }
    it "does not include the owner" do
      expect(presenter.as_json[:owner]).to be(nil)
      expect(Presenters).not_to have_received(:present).with(device.owner, current_user, render_context, with_devices: false)
    end
  end

  context "when the user is authorized to view the device's private info" do

    let(:show_private_info) { true }
    context "when the never_authorized option is true" do

      let(:options) { { never_authorized: true } }

      it "does not include the hardware status message" do
        expect(presenter.as_json[:hardware][:last_status_message]).to be(nil)
      end

      it "includes hardware status_message in the hardware unauthorized_fields" do
        expect(presenter.as_json[:hardware][:unauthorized_fields]).to include(:last_status_message)
      end

      it "does not include the data_policy" do
        expect(presenter.as_json[:data_policy]).to be(nil)
      end

      it "includes the data_policy in the unauthorized_fields" do
        expect(presenter.as_json[:unauthorized_fields]).to include(:data_policy)
      end

      it "does not include the device_token" do
        expect(presenter.as_json[:device_token]).to be(nil)
      end

      it "includes the device_token in the unauthorized_fields" do
        expect(presenter.as_json[:unauthorized_fields]).to include(:device_token)
      end

      it "does not include the mac_address" do
        expect(presenter.as_json[:mac_address]).to be(nil)
      end

      it "includes the mac_address in the unauthorized_fields" do
        expect(presenter.as_json[:unauthorized_fields]).to include(:mac_address)
      end
    end


    context "when the never_authorized option is false" do
      let(:options) { { never_authorized: false } }

      it "includes the hardware status message" do
        expect(presenter.as_json[:hardware][:last_status_message]).to eq(device.hardware_info)
      end

      it "does not include hardware unauthorized_fields" do
        expect(presenter.as_json[:hardware]).not_to include(:unauthorized_fields)
      end

      it "includes the data_policy" do
        expect(presenter.as_json[:data_policy][:is_private]).to eq(device.is_private)
        expect(presenter.as_json[:data_policy][:enable_forwarding]).to eq(device.enable_forwarding)
        expect(presenter.as_json[:data_policy][:precise_location]).to eq(device.precise_location)
      end

      it "includes the device_token" do
        expect(presenter.as_json[:device_token]).to eq(device.device_token)
      end

      it "includes the mac_address" do
        expect(presenter.as_json[:mac_address]).to eq(device.mac_address)
      end

      it "does not include unauthorized_fields" do
        expect(presenter.as_json).not_to include(:unauthorized_fields)
      end
    end
  end

  context "when the user is not authorized to view the device's private info" do
    let(:show_private_info) { false }
    it "does not include the hardware status message" do
      expect(presenter.as_json[:hardware][:last_status_message]).to be(nil)
    end

    it "includes hardware status_message in the hardware unauthorized_fields" do
      expect(presenter.as_json[:hardware][:unauthorized_fields]).to include(:last_status_message)
    end

    it "does not include the data_policy" do
      expect(presenter.as_json[:data_policy]).to be(nil)
    end

    it "includes the data_policy in the unauthorized_fields" do
      expect(presenter.as_json[:unauthorized_fields]).to include(:data_policy)
    end

    it "does not include the mac_address" do
      expect(presenter.as_json[:mac_address]).to be(nil)
    end

    it "includes the mac_address in the unauthorized_fields" do
      expect(presenter.as_json[:unauthorized_fields]).to include(:mac_address)
    end
  end


end
