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
    create?
  end

  def update_password?
    Rails.logger.info user
    Rails.logger.info record
    update?
  end

end
