class AddNotificationsToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :notify_stopped_publishing_timestamp, :timestamp, :default => Time.now
    add_column :devices, :notify_low_battery_timestamp, :timestamp, :default => Time.now
    add_column :devices, :notify_low_battery, :boolean, default: false
    add_column :devices, :notify_stopped_publishing, :boolean,default: false
  end
end
