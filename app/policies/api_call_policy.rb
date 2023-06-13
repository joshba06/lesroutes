class ApiCallPolicy < ApplicationPolicy

  def add_directions?
    true
  end

  def add_maploads?
    true
  end

  def add_geocoding?
    true
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
