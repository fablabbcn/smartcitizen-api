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

  def destroy?
    user == record
  end

  def request_password_reset?
    create?
  end

  def update_password?
    create?
  end

  def show_private_info?
    update?
  end

  def show_secrets?
    user.try(:is_admin?) || user == record
  end

  def register_device?
    user == record
  end

  def create_experiment?
    user == record
  end
end
