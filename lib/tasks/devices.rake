namespace :devices do
  task :truncate_and_fuzz_locations => :environment do
    Device.all.each do |device|
      device.truncate_and_fuzz_location!
      device.save!(validate: false)
    end
  end

  task :set_first_reading_at => :environment do
    from_date = Device.order(:created_at).first.created_at
    Device.where(state: "has_published").each do |device|
      component = device.components.where("last_reading_at IS NOT NULL").first
      if component
        begin
          readings = Kairos.query(id: device.id, sensor_key: component.key, function: "first", rollup: "1s", limit: 1, start_absolute: from_date)["readings"]
          first_reading_timestamp = readings[0][0] if readings&.any?
          device.update_columns(first_reading_at: first_reading_timestamp) if first_reading_timestamp
        rescue JsonNull
          nil
        end
      end
      print "."
    end
    print "\n"
  end
end
