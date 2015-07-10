class UserPolicy < ApplicationPolicy

  def show?
    true
  end

  def create?
    !user || user.is_admin?
  end

  def update?
    user.try(:is_admin?) || user == record
  end

  def request_password_reset?
    create?
  end

  def update_password?
    update?
  end

end
