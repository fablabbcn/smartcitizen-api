class SensorPolicy < ApplicationPolicy

  def show?
    true
  end

  def create?
    user.try(:is_admin?)
  end

  def destroy?
    create?
  end

  def update?
    create?
  end

end
