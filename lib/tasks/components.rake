namespace :components do
  task :remove_duplicates => :environment do
    puts "WARNING: This task is potentially destructive. Before continuing please ensure that you have made a database backup. Press 'y' to continue or any other key to exit."
    ch = STDIN.getch
    unless ch == "y"
      abort
    end

    pre_migrate_sensor_counts = ActiveRecord::Base.connection.execute(
      "SELECT device_id, count(distinct sensor_id) FROM components GROUP BY device_id"
    ).to_a

    devices_and_sensors_with_dupes = ActiveRecord::Base.connection.execute(
      "SELECT device_id, sensor_id FROM components GROUP BY device_id, sensor_id HAVING count(id) > 1"
    )

    removed = 0

    devices_and_sensors_with_dupes.each do |record|
      device_id = record["device_id"]
      sensor_id = record["sensor_id"]
      last_updated_component = Component.where(device_id: device_id, sensor_id: sensor_id).order("last_reading_at DESC").first
      all_components = Component.where(device_id: device_id, sensor_id: sensor_id, key: last_updated_component.key).all
      components_to_remove = all_components - [last_updated_component]
      removed += components_to_remove.length
      components_to_remove.each(&:destroy!)
    end

      post_migrate_sensor_counts = ActiveRecord::Base.connection.execute(
        "SELECT device_id, count(distinct sensor_id) FROM components GROUP BY device_id"
      ).to_a

      if pre_migrate_sensor_counts == post_migrate_sensor_counts
        puts "components deduplicated ok, #{removed} components deleted for #{devices_and_sensors_with_dupes.to_a.length} device/sensor pairs."
      else
        raise "Number of sensors per device pre deduplication does not match number post duplication. Please revert to the db backup and inspect."
      end
  end
end

