namespace :sqlmigrate do

  task :users => :environment do
    LegacyUser.all.each do |old_user|
      User.unscoped.where(id: old_user.id).first_or_initialize.tap do |user|
        # if user.new_record?
          user.username ||= old_user.username#.present? ? old_user.username.try(:strip) : nil
          user.city ||= old_user.city#.present? ? old_user.city.try(:strip).try(:titleize) : nil
          # user.country_code = ISO3166::Country.find_country_by_name(old_user.country.try(:strip)).try(:alpha2)
          user.url ||= old_user.website#.present? ? old_user.username.try(:strip) : nil
          user.email ||= old_user.email#.present? ? old_user.email.try(:strip).try(:downcase) : nil
          user.created_at = old_user.created
          user.updated_at = old_user.modified
          # if old_user.api_key
          user.legacy_api_key ||= old_user.api_key
          # end
          begin
            user.save! validate: false
            p user.id
          rescue ActiveRecord::RecordInvalid => e
            puts [user.id, e.message].join(' >> ')
          rescue Exception => e
            puts e
          end
        # end
      end
    end
  end

  task :devices => :environment do
    LegacyDevice.all.each do |old_device|
      Device.unscoped.where(id: old_device.id).first_or_initialize.tap do |device|
        # if device.new_record?
          device.name ||= old_device.title.present? ? old_device.title : nil
          device.owner_id ||= old_device.user_id.present? ? old_device.user_id : nil
          device.description = old_device.description.present? ? old_device.description : nil
          device.city = old_device.city.present? ? old_device.city : nil
          device.exposure ||= old_device.exposure.present? ? old_device.exposure : nil
          device.elevation ||= old_device.elevation.present? ? old_device.elevation : nil
          device.latitude = old_device.geo_lat.present? ? old_device.geo_lat : nil
          device.longitude = old_device.geo_long.present? ? old_device.geo_long : nil
          device.created_at = old_device.created
          device.updated_at = old_device.modified
          device.workflow_state ||= "active"
          begin
            device.save! validate: false
            p device.id
          rescue ActiveRecord::RecordInvalid => e
            puts [device.id, e.message].join(' >> ')
          rescue Exception => e
            puts e
          end
        # end
      end
    end
  end

end
