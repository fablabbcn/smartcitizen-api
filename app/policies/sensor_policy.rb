class SensorPolicy < ApplicationPolicy

  def show?
    true
  end

  def create?
    user.try(:is_admin?)
  end

  def update?
    create?
  end

end
