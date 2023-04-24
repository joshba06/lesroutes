class CreateApiCalls < ActiveRecord::Migration[7.0]
  def change
    create_table :api_calls do |t|
      t.string :directions
      t.string :maploads
      t.string :geocoding

      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
