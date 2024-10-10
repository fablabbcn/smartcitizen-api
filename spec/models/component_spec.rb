require 'rails_helper'

RSpec.describe Component, :type => :model do
  it { is_expected.to belong_to(:device) }
  it { is_expected.to belong_to(:sensor) }
  it { is_expected.to validate_presence_of(:device) }
  it { is_expected.to validate_presence_of(:sensor) }

  it "validates uniqueness of board to sensor" do
    component = create(:component, device: create(:device), sensor: create(:sensor))
    expect{ create(:component, device: component.device, sensor: component.sensor) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  describe "creating a unique sensor key" do
    let(:component) {
      create(:component, device: create(:device), sensor: create(:sensor))
    }

    describe "when the given key is not in the list of existing keys" do
      it "uses the key as is" do
        generated_key = component.get_unique_key("key", ["other"])
        expect(generated_key).to eq("key")
      end
    end

    describe "when the given key is in the list of existing keys" do
      it "adds an incremeting number to the key" do
        generated_key = component.get_unique_key("key", ["key", "other", "key_1"])
        expect(generated_key).to eq("key_2")
      end
    end
  end

end
