class AddTimeToRoutes < ActiveRecord::Migration[7.0]
  def change
    add_column :routes, :time, :string
  end
end
