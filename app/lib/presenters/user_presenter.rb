module Presenters
  class UserPresenter < BasePresenter

    alias_method :user, :model

    def default_options
      {
        with_devices: true
      }
    end

    def exposed_fields
      %i{id uuid role username profile_picture url location email legacy_api_key devices created_at updated_at}
    end

    def profile_picture
      render_context&.profile_picture_url(user)
    end

    def email
      user.email if authorized?
    end

    def legacy_api_key
      user.legacy_api_key if authorized?
    end

    def devices
      present(user.devices) if options[:with_devices]
    end

    private

    def authorized?
      policy.show_private_info?
    end

    def policy
      @policy ||= UserPolicy.new(current_user, user)
    end
  end
end
