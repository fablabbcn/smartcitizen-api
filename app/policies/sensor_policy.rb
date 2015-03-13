class SensorPolicy < ApplicationPolicy

  def show?
    true
  end

  def create?
    user#.try(:admin?)
  end

end
