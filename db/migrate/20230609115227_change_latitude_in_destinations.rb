class ChangeLatitudeInDestinations < ActiveRecord::Migration[7.0]
  def self.up
    change_column :destinations, :latitude, :numeric, :precision => 11, :scale => 8
    change_column :destinations, :longitude, :numeric, :precision => 11, :scale => 8
  end
end
