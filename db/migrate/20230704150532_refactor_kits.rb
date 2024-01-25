require 'csv'
class RefactorKits < ActiveRecord::Migration[6.0]

  def execute(query, args=[])
    args = [args] unless args.is_a?(Array)
    sanitized = ActiveRecord::Base.send(:sanitize_sql_array, [query] + args)
    ActiveRecord::Base.connection.execute(sanitized)
  end

  def change

    # To start, create a hash of all devices to their sensors, to use as a check later on:
    device_sensors_pre = Hash.new {|h, k| h[k] = []; }
    execute("""
      SELECT devices.id AS device_id, components.sensor_id AS sensor_id
      FROM devices
      INNER JOIN components on components.board_id = devices.kit_id
        AND components.board_type = 'Kit'
      ORDER BY device_id, sensor_id ASC
    """).each do |row|
      device_sensors_pre[row["device_id"]] << row["sensor_id"]
    end


    # Add columns needed in new schema:
    change_table :components do |t|
      t.column :device_id, :integer
      t.column :key, :string, null: true
    end
    change_column_null :components, :board_id, true
    change_column_null :components, :board_type, true

    change_table :sensors do |t|
      t.column :default_key, :string, null: true
      t.column :equation, :string, null: true
      t.column :reverse_equation, :string, null: true
    end

    change_table :devices do |t|
      t.column :hardware_type_override, :string, null: true
      t.column :hardware_name_override, :string, null: true
      t.column :hardware_version_override, :string, null: true
      t.column :hardware_description_override, :string, null: true
      t.column :hardware_slug_override, :string, null: true
    end

    # Add default key to sensors to be used when new components are created:
    puts "-- setting default keys for sensors"

    key_counter =  Hash.new { |h, k|
      h[k] = Hash.new {|h2, k2|
        h2[k2] = 0
      }
    }

    execute("SELECT sensor_map FROM kits").each { |row|
       m = JSON.parse(row["sensor_map"])
       m.each { |k, v| key_counter[v][k] += 1 }
    }

    key_counter.each do |id, keys|
      key = keys.max_by {|k, v| v }[0]
      execute("UPDATE sensors SET default_key=? WHERE id=?", [key, id])
    end


    # Add equations to sensors:
    puts "-- setting equations for sensors"

    execute("""
      SELECT  sensor_id,
      COUNT(DISTINCT equation) AS count_equation,
      COUNT(DISTINCT reverse_equation) AS count_reverse_equation
      FROM components
      GROUP BY sensor_id
    """).each do |row|
      sensor_id = row["sensor_id"]
      if row["count_equation"] == 1 && row["count_reverse_equation"] == 1
        equations = execute("""
          SELECT equation, reverse_equation
          FROM components
          WHERE sensor_id = ?
          LIMIT 1
        """, sensor_id)[0]
        execute("""
          UPDATE sensors
          SET equation = ?,
              reverse_equation = ?
          WHERE id = ?
        """, [equations["equation"], equations["reverse_equation"], sensor_id])
      end
    end

    # For each existing device. Look up its kit, set its hardware_info, and create a component for each of that kit's components, with reference to the device itself.

    kits_info =  CSV.foreach("db/data/kits.csv", headers:true).map(&:to_h).reduce({}) { |h, r| h[r["id"].to_i] = r; h }


    puts "-- setting hardware info and creating components for devices"

    execute("SELECT * FROM devices").each do |device_row|
      execute("SELECT * FROM kits WHERE id = ? LIMIT 1", device_row["kit_id"]).each do |kit_row|

        device_id = device_row["id"]

        kit_id = kit_row["id"]
        kit_info = kits_info[kit_id]

        hardware_version = kit_info["hardware_version"]

        unless kit_info["hardware_type"] == "SCK"
          hardware_type = kit_info["hardware_type"]
        end

        default_name = "SmartCitizen Kit #{hardware_version}"
        unless kit_info["hardware_name"] == default_name
          hardware_name = kit_info["hardware_name"]
        end

        default_slug = "#{kit_info["hardware_type"].downcase}:#{hardware_version.gsub(".", ",")}"
        unless kit_info["slug"] == default_slug
          hardware_slug = kit_info["slug"]
        end

        unless kit_info["hardware_description"] == kit_info["hardware_name"]
          hardware_description =   kit_info["hardware_description"]
        end

        execute("""
          UPDATE devices
          SET
            hardware_version_override = ?,
            hardware_type_override = ?,
            hardware_name_override = ?,
            hardware_description_override = ?,
            hardware_slug_override = ?
          WHERE id = ?
        """, [hardware_version, hardware_type, hardware_name, hardware_description, hardware_slug, device_id])


        kit_component_rows = execute("""
          SELECT * FROM components
          WHERE board_type = 'Kit'
          AND board_id = ?
        """, kit_row["id"])
        sensor_map = JSON.parse(kit_row["sensor_map"])
        kit_component_rows.each do |kit_component_row|
          sensor_row = execute("SELECT * FROM sensors WHERE id = ?", kit_component_row["sensor_id"])[0]
          device_id = device_row["id"]
          sensor_id = sensor_row["id"]
          created_at = kit_component_row["created_at"]
          updated_at = kit_component_row["updated_at"]
          key = sensor_map.invert[sensor_id]
          execute("""
            INSERT INTO components
            (device_id, sensor_id, key, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?)
          """, [device_id, sensor_id, key, created_at, updated_at])
        end
      end
    end

    # Check the devices / sensors mapping we created before against the current
    # state:

    puts "-- checking device sensors state matches previous"

    device_sensors_post = Hash.new {|h, k| h[k] = [] }
    execute("""
      SELECT devices.id AS device_id, components.sensor_id AS sensor_id
      FROM devices
      INNER JOIN components on components.device_id = devices.id
      ORDER BY device_id, sensor_id ASC
    """).each do |row|
      device_sensors_post[row["device_id"]] << row["sensor_id"]
    end

    unless device_sensors_pre == device_sensors_post
      raise "Check failed - device sensors not the same before and after migration!"
    end

    # Delete deprecated columns and tables:
    change_table :orphan_devices do |t|
      t.remove :kit_id
    end

    change_table :components do |t|
      t.remove :board_id
      t.remove :board_type
      t.remove :equation
      t.remove :reverse_equation
    end

    change_table :devices do |t|
      t.remove :kit_id
    end

    drop_table :kits

    # Remove the old component records:
    execute "DELETE FROM components WHERE device_id IS NULL"

    # Set constraints on components and sensors for the new device relationshop:
    change_column_null :components, :device_id, false
    add_foreign_key :components, :devices
    change_column_null :components, :key, null: false
    change_column_null :sensors, :default_key, null: false
  end
end
