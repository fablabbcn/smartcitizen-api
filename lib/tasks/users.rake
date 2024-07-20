namespace :users do
    task :remove_null_emails => :environment do
        team_user = User.find_by_email("team@pral2a.com")
        count_team_devices = team_user.devices.length
        count_users = User.count
        count_moved_devices = 0
        count_deleted_users = 0
        User.where("email IS NULL or trim(email) = ''").each do |user|
            puts "user #{user.id} (#{user.username}) has blank email, moving devices to team account:"
            user.devices.each do |device|
                device.owner = team_user
                device.save(validate: false)
                count_team_devices += 1
                count_moved_devices += 1
                puts "\t - Device #{device.id} moved to user: #{team_user.id}"
            end
            user.destroy!
            count_users -= 1
            count_deleted_users += 1
        end
        puts "Check moved devices: #{team_user.reload.devices.length} (should be #{count_team_devices}, #{count_moved_devices} moved)"
        puts "Check remaining users: #{User.count} (should be #{count_users}, #{count_deleted_users} deleted)"
    end

    task :deduplicate_emails => :environment do
        count_deleted_users = 0
        count_users = User.count
        count_devices = Device.count
        count_moved_devices = 0
        ActiveRecord::Base.connection.execute(
            "SELECT email FROM users GROUP BY email HAVING count(id) > 1"
        ).each do |record|
            email = record["email"]
            users = User.where(email: email).to_a
            puts "Found #{users.length} users for email: #{email}: (#{users.map(&:id).join(",")})"
            move_to_user = users.shift
            puts " - Moving devices from users (#{users.map(&:id).join(",")}) to user #{move_to_user.id}"
            users.each do |user|
                user.devices.each do |device|
                    device.owner = move_to_user
                    device.save(validate: false)
                    count_moved_devices += 1
                    puts "  - Moved device #{device.id} to user: #{move_to_user.id}"
                end
            end
            puts " - Deleting users: #{users.map(&:id).join(",")}"
            users.each do |user|
                user.destroy!
                count_deleted_users += 1
            end
        end
        puts "Check moved devices: #{Device.count} (should be #{count_devices}, #{count_moved_devices} moved)"
        puts "Check deleted users: #{User.count} (should be #{count_users - count_deleted_users}, #{count_deleted_users} deleted)"
    end

    task :generate_forwarding_tokens => :environment do
      User.where("role_mask >= 4 AND forwarding_token IS NULL").each do |user|
        puts "Generating tokens for user #{user.username} (role_mask: #{user.role_mask}, id: #{user.id})"
        user.regenerate_forwarding_tokens!
        user.save!
      end
    end
end
