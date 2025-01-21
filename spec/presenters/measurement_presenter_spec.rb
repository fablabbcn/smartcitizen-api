require "rails_helper"
describe Presenters::MeasurementPresenter do

  let(:measurement) {
    FactoryBot.create(:measurement)
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

  subject(:presenter) { Presenters::MeasurementPresenter.new(measurement, current_user, render_context, options) }

  it "exposes the id" do
    expect(presenter.as_json[:id]).to eq(measurement.id)
  end

  it "exposes the name" do
    expect(presenter.as_json[:name]).to eq(measurement.name)
  end

  it "exposes the description" do
    expect(presenter.as_json[:description]).to eq(measurement.description)
  end

  it "exposes the unit" do
    expect(presenter.as_json[:unit]).to eq(measurement.unit)
  end

  it "exposes the uuid" do
    expect(presenter.as_json[:uuid]).to eq(measurement.uuid)
  end

  it "exposes the description" do
    expect(presenter.as_json[:description]).to eq(measurement.description)
  end
end
