module Presenters
  class DevicePresenter < BasePresenter
    alias_method :device, :model

    def default_options
      {
        with_owner: true,
        with_data: true,
        with_postprocessing: true,
        with_location: true,
        slim_owner: false,
        never_authorized: false,
        readings: nil
      }
    end

    def exposed_fields
      %i{id uuid name description state system_tags user_tags last_reading_at created_at updated_at notify device_token mac_address postprocessing location data_policy hardware owner components}
    end

    def notify
      {
        stopped_publishing: device.notify_stopped_publishing,
        low_battery: device.notify_low_battery
      }
    end

    def location
      if options[:with_location]
        {
          exposure: device.exposure,
          elevation: device.elevation.try(:to_i) ,
          latitude: device.latitude,
          longitude: device.longitude,
          geohash: device.geohash,
          city: device.city,
          country_code: device.country_code,
          country: device.country_name
        }
      end
    end

    def data_policy
      {
        is_private: authorized? ? device.is_private : "[FILTERED]",
        enable_forwarding: authorized? ? device.enable_forwarding : "[FILTERED]",
        precise_location: authorized? ? device.precise_location : "[FILTERED]"
      }
    end

    def hardware
      {
        name: device.hardware_name,
        type: device.hardware_type,
        version: device.hardware_version,
        slug: device.hardware_slug,
        last_status_message: authorized? ? device.hardware_info : "[FILTERED]",
      }
    end

    def owner
      if options[:with_owner] && device.owner
        present(device.owner, with_devices: false)
      end
    end

    def postprocessing
      device.postprocessing if options[:with_postprocessing]
    end

    def device_token
      authorized? ? device.device_token : "[FILTERED]"
    end

    def mac_address
      authorized? ? device.mac_address : "[FILTERED]"
    end

    def components
      present(device.components)
    end

    private

    def authorized?
      !options[:never_authorized] && policy.show_private_info?
    end

    def policy
      @policy ||= DevicePolicy.new(current_user, device)
    end

  end
end
