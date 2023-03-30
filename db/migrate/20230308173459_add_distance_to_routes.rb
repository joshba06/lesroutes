class AddDistanceToRoutes < ActiveRecord::Migration[7.0]
  def change
    add_column :routes, :distance, :string
  end
end
