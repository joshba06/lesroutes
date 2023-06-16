class AddFullAddressToDestinations < ActiveRecord::Migration[7.0]
  def change
    add_column :destinations, :full_address, :text
  end
end
