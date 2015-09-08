class CreateDevicesTags < ActiveRecord::Migration
  def change
    create_table :devices_tags do |t|
      t.belongs_to :device, foreign_key: true
      t.belongs_to :tag, foreign_key: true
      t.timestamps null: false
    end

    add_index :devices_tags, [:device_id, :tag_id], unique: true
  end
end
