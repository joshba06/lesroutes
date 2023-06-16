class RouteDestinationPolicy < ApplicationPolicy

  def move?
    route = Route.find(record.route_id)
    route.user == user
  end

  def destroy?
    route = Route.find(record.route_id)
    route.user == user
  end


  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end
end
