class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end

  def restrict_to(min, max)
    [self, min, max].sort[1]
  end
end
