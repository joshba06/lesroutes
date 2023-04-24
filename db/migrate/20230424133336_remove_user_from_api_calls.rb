class RemoveUserFromApiCalls < ActiveRecord::Migration[7.0]
  def change
    remove_reference :api_calls, :user, index: true, foreign_key: true
  end
end
