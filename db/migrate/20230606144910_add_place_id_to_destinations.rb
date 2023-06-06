class AddPlaceIdToDestinations < ActiveRecord::Migration[7.0]
  def change
    add_column :destinations, :place_id, :string
  end
end
