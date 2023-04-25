class AddUnspecificPlacenameToDestinations < ActiveRecord::Migration[7.0]
  def change
    add_column :destinations, :unspecific_placename, :boolean
    change_column_default(:destinations, :unspecific_placename, false)
  end
end
