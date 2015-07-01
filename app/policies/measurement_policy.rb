class MeasurementPolicy < ApplicationPolicy

  def show?
    true
  end

  def create?
    user#.try(:admin?)
  end

  def update?
    create?
  end

end
