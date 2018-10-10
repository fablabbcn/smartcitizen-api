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
  class Unauthorized < SmartCitizenError; end
  class NotFound < SmartCitizenError; end
  class InternalServerError < SmartCitizenError; end

  class Application < Rails::Application

    # console do
    #   ActiveRecord::Base.logger = Rails.logger = Logger.new(STDOUT)
    # end

    # config.middleware.use ActionDispatch::Flash
    # config.action_controller.allow_forgery_protection = false

    unless Rails.env.test?
      log_level = String(ENV['LOG_LEVEL'] || "info").upcase
      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger.const_get(log_level)
      config.log_level = log_level
      config.lograge.enabled = true
      config.lograge.custom_options = lambda do |event|
        {:time => event.time}
      end
    end

    config.middleware.insert_before 0, "HeaderCheck"
    config.middleware.insert_before(ActionDispatch::Static, "DeleteResponseHeaders")

    config.active_job.queue_adapter = :sidekiq

    # Enable Rails CORS only in Development.
    # Otherwise it's done by NGINX.
    if Rails.env.development?
      config.middleware.insert_before 0, "Rack::Cors" do
        allow do
          origins '*'
          resource '*', :headers => :any, :methods => [:get, :post, :put, :patch, :delete, :options]
        end
      end
    end

    # gzip
    # config.middleware.use Rack::Deflater

    config.autoload_paths += %W(#{config.root}/lib app/models/concerns)

    config.banned_words = YAML.load_file("#{Rails.root}/config/banned_words.yml").map(&:values).flatten

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
    config.i18n.default_locale = :en

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # config.cache_store = :redis_store, (ENV["REDISCLOUD_URL"] || ENV['REDIS_URL']), { expires_in: 90.minutes }

    config.exceptions_app = self.routes

    config.assets.enabled = false

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

  end
end
