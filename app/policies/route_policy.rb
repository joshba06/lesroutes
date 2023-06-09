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


  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end


end
