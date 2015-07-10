class MeasurementPolicy < ApplicationPolicy

  def show?
    true
  end

  def create?
    user
  end

  def update?
    create?
  end

end
