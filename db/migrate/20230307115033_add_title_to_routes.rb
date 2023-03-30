class AddTitleToRoutes < ActiveRecord::Migration[7.0]
  def change
    add_column :routes, :title, :string
  end
end
