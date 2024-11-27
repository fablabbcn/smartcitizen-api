require "rails_helper"
describe Presenters::SensorPresenter do

  let(:sensor) {
    FactoryBot.create(:sensor)
  }

  let(:current_user) {
    FactoryBot.create(:user)
  }

  let(:measurement_presentation) {
    double(:measurement_presentation)
  }

  let(:render_context) {
    double(:render_context)
  }

  let(:options) {
    {}
  }

  subject(:presenter) { Presenters::SensorPresenter.new(sensor, current_user, render_context, options) }

  it "exposes the id" do
    expect(presenter.as_json[:id]).to eq(sensor.id)
  end

  it "exposes the parent_id" do
    expect(presenter.as_json[:parent_id]).to eq(sensor.parent_id)
  end

  it "exposes the name" do
    expect(presenter.as_json[:name]).to eq(sensor.name)
  end

  it "exposes the description" do
    expect(presenter.as_json[:description]).to eq(sensor.description)
  end

  it "exposes the unit" do
    expect(presenter.as_json[:unit]).to eq(sensor.unit)
  end

  it "exposes the created_at date" do
    expect(presenter.as_json[:created_at]).to eq(sensor.created_at)
  end

  it "exposes the updated_at date" do
    expect(presenter.as_json[:updated_at]).to eq(sensor.updated_at)
  end

  it "exposes the uuid" do
    expect(presenter.as_json[:uuid]).to eq(sensor.uuid)
  end

  it "exposes the datasheet" do
    expect(presenter.as_json[:datasheet]).to eq(sensor.datasheet)
  end

  it "exposes the unit_definition" do
    expect(presenter.as_json[:unit_definition]).to eq(sensor.unit_definition)
  end

  it "exposes the tags" do
    expect(presenter.as_json[:tags]).to eq(sensor.tags)
  end

  it "exposes a presentation of the measurement" do
    allow(Presenters).to receive(:present).with(sensor.measurement, current_user, render_context, {}).and_return(measurement_presentation)
    expect(presenter.as_json[:measurement]).to eq(measurement_presentation)
  end
end
