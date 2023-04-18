class AddSignInCountToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :sign_in_count, :integer
    change_column_null(:users, :sign_in_count, false)
    change_column_default(:users, :sign_in_count, 0)

    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string
  end
end
