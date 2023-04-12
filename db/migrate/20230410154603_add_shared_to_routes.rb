class AddSharedToRoutes < ActiveRecord::Migration[7.0]
  def change
    add_column :routes, :shared, :boolean
    change_column_default(:routes, :shared, false)
  end
end
