class TagSensorPolicy < ApplicationPolicy

  def create?
    user.try(:is_admin?)
  end

end
