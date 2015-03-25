require 'rails_helper'

RSpec.describe SCK1, :type => :calibrator do

  describe "noise" do
    it "returns pre-calculated value" do
      expect( SCK1.new(noise: 5).noise ).to eq([5,4500])
      expect( SCK1.new(noise: 40).noise ).to eq([40,6900])
      expect( SCK1.new(noise: 2525).noise ).to eq([2525,10200])
    end

    it "calculates linear regression for mid-point values" do
      expect( SCK1.new(noise: 7).noise ).to eq([7,4900])
      expect( SCK1.new(noise: 33).noise ).to eq([33,6700])
    end
  end

end
