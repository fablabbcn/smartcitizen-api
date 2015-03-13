class PasswordResetPolicy < ApplicationPolicy

  def show?
    true
  end

  def create?
    user
  end

  def update?
    user == record
  end

end
