require 'rails_helper'

RSpec.describe 'SCK', :type => :calibrator do

  it "has to_h" do
    Timecop.freeze do
      sck = SCK1.new(
        noise: 50,
        light: 51,
        panel: 52,
        co: 53,
        bat: 54,
        hum: 55,
        no2: 56,
        nets: 57,
        temp: 58)
      expect(sck.to_h).to eq({
        nil => Time.current.utc,
        14 => 51,
        18 => 52,
        16 => 53,
        17 => 54,
        13 => 55,
        15 => 56,
        0 => 57,
        12 => 58,
        # fix this
        '12_raw' => 58,
        '13_raw' => 55,
        '17_raw' => 54,
        7 => 7000,
        '7_raw' => 50
      })
    end
  end

  it "sets calibrated_at to Time.current.utc" do
    Timecop.freeze { expect(SCK.new.calibrated_at).to eq(Time.current.utc) }
  end

  it "parses version numbers from string" do
    s = SCK.new(versions: '1.1-0.8.5-A')
    expect(s.firmware_version).to eq('0.8.5')
    expect(s.hardware_version).to eq('1.1')
    expect(s.firmware_param).to eq('A')
  end

  it "raises error if noise called directly" do
    expect{ SCK.new(noise: 29) }.to raise_error(RuntimeError)
  end

  describe "restricting bounds" do

    it "temperature" do
      expect(SCK.new(temp: -500).temp).to eq([-500,-300])
      expect(SCK.new(temp: 800).temp).to eq([800,500])
      expect(SCK.new(temp: 30.45).temp).to eq([30.45,30.45])
    end

    it "humidity" do
      expect(SCK.new(hum: -500).hum).to eq([-500,0])
      expect(SCK.new(hum: 1400).hum).to eq([1400,1000])
      expect(SCK.new(hum: 30.45).hum).to eq([30.45,30.45])
    end

    it "bat" do
      expect(SCK.new(bat: -500).bat).to eq([-500,0])
      expect(SCK.new(bat: 1400).bat).to eq([1400,1000])
      expect(SCK.new(bat: 30.45).bat).to eq([30.45,30.45])
    end

  end

end
