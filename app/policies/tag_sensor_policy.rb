class TagSensorPolicy < ApplicationPolicy

  def create?
    user
  end

end
