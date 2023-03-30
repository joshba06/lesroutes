class CreateRouteDestinations < ActiveRecord::Migration[7.0]
  def change
    create_table :route_destinations do |t|
      t.references :route, null: false, foreign_key: true
      t.references :destination, null: false, foreign_key: true

      t.timestamps
    end
  end
end
