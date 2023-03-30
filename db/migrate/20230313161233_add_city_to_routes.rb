class AddCityToRoutes < ActiveRecord::Migration[7.0]
  def change
    add_column :routes, :city, :string
  end
end
