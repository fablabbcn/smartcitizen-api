class DevicePolicy < ApplicationPolicy

  def show?
    true
  end

  def update?
    user == record.owner
  end

  def create?
    user
  end

end
