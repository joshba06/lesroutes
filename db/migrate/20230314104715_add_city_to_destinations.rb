class AddCityToDestinations < ActiveRecord::Migration[7.0]
  def change
    add_column :destinations, :city, :string
  end
end
