require 'rails_helper'

RSpec.describe SCK11, :type => :calibrator do

  describe "noise" do
    it "returns pre-calculated value" do
      expect( SCK11.new(noise: 0).noise ).to eq([0,5000])
      expect( SCK11.new(noise: 2).noise ).to eq([2,5500])
      expect( SCK11.new(noise: 1860).noise ).to eq([1860,10900])
    end

    it "calculates linear regression for mid-point values" do
      expect( SCK11.new(noise: 5).noise ).to eq([5,5700])
      expect( SCK11.new(noise: 170).noise ).to eq([170,6400])
    end
  end

  it "calculates correct temperature" do
    expect( SCK11.new(temp: 19030).temp ).to eq([19030,-20.0])
    expect( SCK11.new(temp: 23000).temp ).to eq([23000,87.0])
  end

  it "calculates correct humidity" do
    expect( SCK11.new(hum: -200).hum ).to eq([-200,66.0])
    expect( SCK11.new(hum: 4).hum ).to eq([4,70.0])
    expect( SCK11.new(hum: 31).hum ).to eq([31,71.0])
  end

end
