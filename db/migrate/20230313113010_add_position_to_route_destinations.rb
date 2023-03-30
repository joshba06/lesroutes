class AddPositionToRouteDestinations < ActiveRecord::Migration[7.0]
  def change
    add_column :route_destinations, :position, :integer
  end
end
