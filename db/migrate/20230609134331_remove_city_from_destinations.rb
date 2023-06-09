class RemoveCityFromDestinations < ActiveRecord::Migration[7.0]
  def change
    remove_column :destinations, :city, :string
  end
end
