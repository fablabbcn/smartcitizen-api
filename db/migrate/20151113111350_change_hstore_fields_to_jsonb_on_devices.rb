class ChangeHstoreFieldsToJsonbOnDevices < ActiveRecord::Migration
  def up
    change_column :devices, :meta, 'jsonb USING CAST(meta AS jsonb)'
    change_column :devices, :location, 'jsonb USING CAST(location AS jsonb)'
  end

  def down
    puts("****************** Data Migration Warning ******************".red)
    puts("This will WIPE meta and location data".yellow)
    puts("press 'y' if you wish to continue".yellow)

    if STDIN.gets.chomp == "y"
      puts("Ok then!".green)
    else
      fail
    end

    remove_column :devices, :meta
    remove_column :devices, :location
    add_column :devices, :meta, :hstore
    add_column :devices, :location, :hstore
  end
end
