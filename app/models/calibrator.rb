class Calibrator

  def self.bat i, v
    return i/10.0
  end

  def self.co i, v
    return i/1000.0
  end

  def self.light i, v
    return i/10.0
  end

  def self.nets i, v
    return i
  end

  def self.no2 i, v
    return i/1000.0
  end

  def self.noise i, v
    return i
  end

  def self.panel i, v
    return i/1000.0
  end

  def self.hum i, v
    if v.to_s == "1.0"
      i = i/10.0
    end
    return i
  end

  def self.temp i, v
    if v.to_s == "1.0"
      i = i/10.0
    end
    return i
  end

end
