ruby '2.6.10'
source 'https://rubygems.org'

gem 'rails', '6.0.3.3'
gem 'sidekiq', '~> 5'
gem 'doorkeeper', '~> 4'

# To resize active storage images:
# Revise if this is needed after Rails 6.0
gem 'image_processing'

gem 'ancestry'
gem 'api-pagination'
gem 'api_cache'
gem 'awesome_print', require: false
gem 'aws-sdk-s3'
gem 'bcrypt'
gem "bootsnap"
gem 'browser'
gem 'c_geohash', require: false
gem 'countries'
gem 'dalli'
gem 'date_validator'
gem 'diffy', require: false
gem 'fast_blank'
gem 'fog-aws'
gem 'friendly_id'
gem 'geocoder'
#gem "google-cloud-storage", "~> 1.11", require: false
gem 'jbuilder'
gem 'kaminari'
gem 'listen'
gem 'mailgun_rails'
gem 'moneta'
gem 'multi_json'
gem 'net-telnet'
gem 'oauth2', require: false
gem 'oj'
gem 'oj_mimic_json'
gem 'parallel', require: false
gem 'pg'
gem 'pg_search'
gem 'premailer-rails'
gem 'puma'
gem 'pundit'
gem 'rack-attack'
gem 'rack-cache'
gem 'rack-contrib'
gem 'rack-cors', require: 'rack/cors'
gem 'rack-timeout', require: "rack/timeout/base"
gem 'ransack'
gem 'redis'
gem 'responders'
gem 'rufus-scheduler'
gem 'sentry-ruby'
gem 'sentry-rails'
gem 'sentry-sidekiq'
gem 'sinatra'
#gem 'skylight'
gem 'stamp'
gem 'versionist', github: 'bploetz/versionist'
gem 'workflow'

# eventMachine MQTT handler
gem 'em-mqtt'

group :production do
  gem 'rails_12factor'
end

group :test do
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
  gem 'zonebie'
end

group :development do
  gem "parallel_tests"
  gem 'pry-rails'
  gem "rails-erd"
  gem 'rubocop', require: false
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'sshkit'
  gem 'sshkit-sudo'
end

group :development, :test do
  # gem 'rspec_api_blueprint', require: false
  gem 'brakeman', github: 'presidentbeef/brakeman', require: false
  gem 'byebug'
  gem 'cane'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'guard-rspec'
  gem 'railroady'
  gem 'rdoc'
  gem 'rspec-rails'
  gem 'shoulda-matchers',
      github: 'thoughtbot/shoulda-matchers',
      require: false,
      ref: '8e68d99217fac5dedceeeba226ea1f2d9be01e1b'
  #gem 'web-console'
end
