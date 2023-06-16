class RoutePolicy < ApplicationPolicy

  def index?
    true
  end

  def show?
    true
  end

  def new?
    create?
  end

  def create?
    true
  end

  def update?
    record.user == user
  end

  def edit?
    update?
  end

  def update_mode_cycling?
    record.user == user
  end

  def update_mode_driving?
    record.user == user
  end

  def update_mode_walking?
    record.user == user
  end

  def updateroutetitle?
    record.user == user
  end

  def updateroutecity?
    record.user == user
  end

  def stop_sharing_route?
    record.user == user
  end

  def share_route?
    record.user == user
  end

  def save?
    record.user == user
  end

  def move?
    record.user == user
  end

  def destroy?
    record.user == user
  end

  def update_google_url?
    true
  end

  def admin?
    user.admin?
  end

  def export?
    user.admin?
  end



  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end


end
