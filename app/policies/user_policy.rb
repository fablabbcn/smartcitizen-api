class UserPolicy < ApplicationPolicy

  def show?
    true
  end

  def create?
    !user
  end

  def update?
    user == record
  end

  def request_password_reset?
    true
  end

  def update_password?
    update?
  end

end
