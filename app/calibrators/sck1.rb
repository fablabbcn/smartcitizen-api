class SCK1 < SCK

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

  def noise=(value)
    db = {5 => 45,10 => 55,15 => 63,20 => 65,30 => 67,40 => 69,50 => 70,60 => 71,80 => 72,90 => 73,100 => 74,130 => 75,160 => 76,190 => 77,220 => 78,260 => 79,300 => 80,350 => 81,410 => 82,450 => 83,550 => 84,600 => 85,650 => 86,750 => 87,850 => 88,950 => 89,1100 => 90,1250 => 91,1375 => 92,1500 => 93,1650 => 94,1800 => 95,1900 => 96,2000 => 97,2125 => 98,2250 => 99,2300 => 100,2400 => 101,2525 => 102,2650 => 103}
    super value, db
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
