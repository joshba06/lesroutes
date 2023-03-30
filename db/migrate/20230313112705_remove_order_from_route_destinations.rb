class RemoveOrderFromRouteDestinations < ActiveRecord::Migration[7.0]
  def change
    remove_column :route_destinations, :order
  end
end
