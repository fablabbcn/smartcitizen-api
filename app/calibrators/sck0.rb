class SCK0 < SCK

  def map
    {
    noise: 7,
    light: 6,
    panel: 11,
    co: 9,
    bat: 10,
    hum: 5,
    no2: 8,
    nets: 21,
    temp: 4
    }
  end

  def temp=(value)
    t = value/10.0
    super value, t
  end

  def hum=(value)
    t = value/10.0
    super value, t
  end

  def light=(value)
    t = value/10.0
    super value, t
  end

  def co=(value)
    t = value/1000.0
    super value, t
  end

  def no2=(value)
    t = value/1000.0
    super value, t
  end

  def panel=(value)
    t = value/1000.0
    super value, t
  end
end
