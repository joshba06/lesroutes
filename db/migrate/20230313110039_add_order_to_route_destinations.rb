class AddOrderToRouteDestinations < ActiveRecord::Migration[7.0]
  def change
    add_column :route_destinations, :order, :integer
  end
end
