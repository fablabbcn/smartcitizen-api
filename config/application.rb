require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "sprockets/railtie"
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
  class NotAuthorized < SmartCitizenError; end
  class NotFound < SmartCitizenError; end
  class InternalServerError < SmartCitizenError; end

  class Application < Rails::Application

    # config.middleware.use ActionDispatch::Flash
    # config.action_controller.allow_forgery_protection = false

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :put, :patch, :delete, :options]
      end
    end

    # gzip
    config.middleware.use Rack::Deflater

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # config.cache_store = :redis_store, (ENV["REDISCLOUD_URL"] || ENV['redis_uri']), { expires_in: 90.minutes }

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
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end

  end
end
