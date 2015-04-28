require 'rails_helper'

RSpec.describe SCK1, :type => :calibrator do

  describe "noise" do
    it "returns pre-calculated value" do
      expect( SCK1.new(noise: 5).noise ).to eq([5,45.00])
      expect( SCK1.new(noise: 40).noise ).to eq([40,69.00])
      expect( SCK1.new(noise: 2525).noise ).to eq([2525,102.00])
    end

    it "calculates linear regression for mid-point values" do
      expect( SCK1.new(noise: 7).noise ).to eq([7,49.00])
      expect( SCK1.new(noise: 74).noise ).to eq([74,71.700])
    end
  end

end
