class CreateOrphanDevices < ActiveRecord::Migration
  def change
    create_table :orphan_devices do |t|
      t.string :name
      t.text :description
      t.integer :kit_id
      t.string :exposure
      t.float :latitude
      t.float :longitude
      t.text :user_tags
      t.string :device_token
      t.string :onboarding_session

      t.timestamps null: false
    end
  end
end
