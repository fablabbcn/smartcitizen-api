require "rails_helper"
describe Presenters::ComponentPresenter do

  let(:sensor_presentation) {
    double(:sensor_presentation)
  }

  let(:component) {
    FactoryBot.create(:component)
  }

  let(:current_user) {
    FactoryBot.create(:user)
  }

  let(:render_context) {
    double(:render_context)
  }

  let(:options) {
    {}
  }

  subject(:presenter) { Presenters::ComponentPresenter.new(component, current_user, render_context, options) }

  it "exposes the last_reading_at date" do
    expect(presenter.as_json[:last_reading_at]).to eq(component.last_reading_at)
  end

  it "exposes a presentation of the sensor" do
    allow(Presenters).to receive(:present).with(component.sensor, current_user, render_context, {}).and_return(sensor_presentation)
    expect(presenter.as_json[:sensor]).to eq(sensor_presentation)
  end

  context "when the component's device has data" do
    it "returns the data for the corresponding sensor as the latest_value" do
      allow(component.device).to receive(:data).and_return({
        component.sensor_id.to_s => 123.0
      })
      expect(presenter.as_json[:latest_value]).to eq(123.0)
    end
  end

  context "when the component's device has no data" do
    it "has no latest_value" do
      expect(presenter.as_json[:latest_value]).to eq(nil)
    end
  end

  context "when the component's device has old_data" do
    it "returns the old data for the corresponding sensor as the previous_value" do
      allow(component.device).to receive(:old_data).and_return({
        component.sensor_id.to_s => 246.0
      })
      expect(presenter.as_json[:previous_value]).to eq(246.0)
    end
  end

  context "when the component's device has no old_data" do
    it "has no previous_value" do
      expect(presenter.as_json[:previous_value]).to eq(nil)
    end
  end

  context "when readings are supplied" do
    let(:reading_timestamp) { Time.now - 6.hours }
    let(:reading_value) { 1234.1 }
    let(:options) {
      {
        readings: [
          #TODO this particular reading format needs to be refactored out
          {
            "" => reading_timestamp,
            "#{component.sensor_id}" => reading_value,
            "#{component.sensor_id + 1}" => 54321.0
          }
        ]
      }
    }

    it "returns the readings formatted with timestamp and value" do
      expect(presenter.as_json[:readings]).to eq([
        { timestamp: reading_timestamp, value: reading_value }
      ])
    end
  end

  context "when readings are not supplied" do
    it "has no readings" do
      expect(presenter.as_json[:readings]).to eq(nil)
    end
  end
end
