class ExperimentPolicy < ApplicationPolicy
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
