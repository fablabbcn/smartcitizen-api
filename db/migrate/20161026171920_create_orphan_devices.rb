class CreateOrphanDevices < ActiveRecord::Migration
  def change
    create_table :orphan_devices do |t|
      t.string :name
      t.text :description
      t.integer :kit_id
      t.string :exposure
      t.float :latitude
      t.integer :longitude
      t.text :user_tags
      t.string :owner_email
      t.string :device_token
      t.string :onboarding_session

      t.timestamps null: false
    end
  end
end
