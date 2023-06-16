class ChangeLongitudeInDestinations < ActiveRecord::Migration[7.0]
  def change
    change_column :destinations, :latitude, :decimal, precision: 10, scale: 6
    change_column :destinations, :longitude, :decimal, precision: 10, scale: 6
  end
end
