module Presenters
  class DevicePresenter < BasePresenter
    alias_method :device, :model

    def default_options
      {
        with_owner: true,
        with_postprocessing: true,
        with_location: true,
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
      authorize!(:data_policy) do
        {
          is_private: device.is_private,
          enable_forwarding: device.enable_forwarding,
          precise_location: device.precise_location
        }
      end
    end

    def hardware
      {
        name: device.hardware_name,
        type: device.hardware_type,
        version: device.hardware_version,
        slug: device.hardware_slug,
        last_status_message: authorize!(:hardware, :last_status_message) { device.hardware_info },
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
      authorize!(:device_token) { device.device_token }
    end

    def mac_address
      authorize!(:mac_address) { device.mac_address }
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
