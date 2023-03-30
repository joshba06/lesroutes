class AddGoogleUrlToRoutes < ActiveRecord::Migration[7.0]
  def change
    add_column :routes, :google_url, :text
  end
end
