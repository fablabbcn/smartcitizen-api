class KitPolicy < ApplicationPolicy

  def show?
    true
  end

  def update?
    user
  end

end
