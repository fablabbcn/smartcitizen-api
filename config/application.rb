require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
#require "sprockets/railtie"
# require "rails/test_unit/railtie"
# require 'actionpack/action_caching'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Smartcitizen

  class SmartCitizenError < StandardError
    def initialize(errors = nil)
      @message = errors
    end

    def message
      @message
    end
  end

  class UnprocessableEntity < SmartCitizenError; end
  class Unauthorized < SmartCitizenError; end
  class NotFound < SmartCitizenError; end
  class InternalServerError < SmartCitizenError; end

  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    #config.load_defaults 6.0
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.

    config.active_job.queue_adapter = :sidekiq

    # Throttling
    config.middleware.use Rack::Attack

    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc

    config.i18n.default_locale = :en

    config.exceptions_app = self.routes

    config.generators do |g|
      g.helper false
      g.assets false
      g.test_framework :rspec,
        helper: false,
        assets: false,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: true,
        request_specs: false
    end

    if ENV['RAVEN_DSN_URL'].present?
      Raven.configure do |config|
        config.dsn = ENV['RAVEN_DSN_URL']
        config.environments = [ 'staging', 'production' ]
      end
    end

    # Needed for rails_admin
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Flash
    config.middleware.use Rack::MethodOverride
    config.middleware.use ActionDispatch::Session::CookieStore, {:key=>"_smartcitizen_session"}
    # end rails_admin

    config.api_only = true
  end
end
