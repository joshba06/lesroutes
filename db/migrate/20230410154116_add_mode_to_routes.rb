class AddModeToRoutes < ActiveRecord::Migration[7.0]
  def change
    add_column :routes, :mode, :string
    change_column_default(:routes, :mode, 'walking')
  end

end
