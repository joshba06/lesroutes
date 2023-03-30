class AddAddressToDestinations < ActiveRecord::Migration[7.0]
  def change
    add_column :destinations, :address, :string
  end
end
