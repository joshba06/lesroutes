class ChangeFullAddressInDestinations < ActiveRecord::Migration[7.0]
  def change
    change_column(:destinations, :full_address, :string)
  end
end
