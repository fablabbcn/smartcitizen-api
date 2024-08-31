class DevicePolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user
        if user.is_admin?
          # Admins get everything
          scope
        else
          # Non admins should get all non_private + the Devices they own
          scope.where(is_private: false).or(scope.where(owner_id: user.id))
        end
      else
        # not logged in
        scope.where(is_private: false)
      end
    end
  end

  def show_private_info?
    admin_or_owner?
  end

  def show?
    if record.is_private?
      admin_or_owner?
    else
      true
    end
  end

  def update?
    admin_or_owner?
  end

  def admin_or_owner?
    user.try(:is_admin?) || user == record.owner
  end

  def create?
    user
  end

  def destroy?
    update?
  end
end
