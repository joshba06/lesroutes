class AddLikesToRoutes < ActiveRecord::Migration[7.0]
  def change
    add_column :routes, :likes, :integer
    change_column_default(:routes, :likes, 0)
  end
end
