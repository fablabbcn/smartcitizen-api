class DevicePolicy < ApplicationPolicy

  def show?
    true
  end

  def update?
    user.try(:admin?) or user == record.owner
  end

  def create?
    user
  end

end
