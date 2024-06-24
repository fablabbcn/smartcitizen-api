namespace :devices do
  task :truncate_and_fuzz_locations => :environment do
    Device.all.each do |device|
      device.truncate_and_fuzz_location!
      device.save!(validate: false)
    end
  end
end
