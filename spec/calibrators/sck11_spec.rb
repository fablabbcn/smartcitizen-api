require 'rails_helper'

RSpec.describe SCK11, :type => :calibrator do

  describe "noise" do
    it "returns pre-calculated value" do
      expect( SCK11.new(noise: 0).noise ).to eq([0,50.00])
      expect( SCK11.new(noise: 2).noise ).to eq([2,55.00])
      expect( SCK11.new(noise: 1860).noise ).to eq([1860,109.00])
    end

    it "calculates linear regression for mid-point values" do
      expect( SCK11.new(noise: 5).noise ).to eq([5,57.666666666666664])
      expect( SCK11.new(noise: 170).noise ).to eq([170,64.66666666666667])
    end
  end

  it "calculates correct temperature" do
    expect( SCK11.new(temp: 22788).temp ).to eq([22788,8.100881347656248])
  end

  it "calculates correct humidity" do
    expect( SCK11.new(hum: 37488).hum ).to eq([37488,78.502685546875])
  end

end
