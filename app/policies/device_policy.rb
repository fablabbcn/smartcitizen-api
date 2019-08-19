class DevicePolicy < ApplicationPolicy

  def show?
    if record.is_private?
      update?
    else
      true
    end
  end

  def update?
    user.try(:is_admin?) || user == record.owner
  end

  def create?
    user
  end

  def destroy?
    update?
  end
end
