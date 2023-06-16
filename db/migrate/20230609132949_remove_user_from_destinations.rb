class RemoveUserFromDestinations < ActiveRecord::Migration[7.0]
  def change
    remove_reference :destinations, :user, index: true, foreign_key: true
    remove_column :destinations, :unspecific_placename, :boolean
  end
end
