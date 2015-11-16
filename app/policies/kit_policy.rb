class KitPolicy < ApplicationPolicy

  def show?
    true
  end

  def create?
    user and user.is_admin?
  end

  def update?
    create?
  end

end
