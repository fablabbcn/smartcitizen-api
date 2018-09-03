ruby '2.3.7'
source 'https://rubygems.org'

gem 'rails', '~> 4.2.10'
gem 'rails-api'
gem 'pg', '~> 0.20' # pg 1 only works on rails 5.1.5+

gem 'redis'#, '3.0.7'
#gem 'skylight', '~> 1.2', '>= 1.2.2'

gem 'rack-timeout', require: "rack/timeout/base"
gem 'rack-cors', require: 'rack/cors'
gem 'rack-contrib'
gem 'rack-cache'
gem 'moneta'
gem 'api_cache'
gem 'minuteman'#, '~> 2'

gem 'browser'#, '1.0.1'
gem 'stamp'
gem 'listen'#, '~> 3.0.0'
#gem 'airbrake', '~> 4.3'
gem 'premailer-rails'
# gem 'statsample'
# gem 'upsert'

gem 'lograge'
gem 'figaro'
gem 'versionist', github: 'bploetz/versionist'
gem 'jbuilder'
gem 'responders'
gem 'newrelic_rpm'
gem 'net-telnet'
gem 'workflow'

gem 'bcrypt'#, '~> 3.1.7'
gem 'aws-sdk'

gem 'redis-rails'

gem 'sinatra'#, '>= 1.3.0', require: nil
gem 'sidekiq', '~> 4.0' # Upgrade to 5 with rails. BREAKING CHANGES

gem 'fog'

gem 'oauth2', require: false
gem 'doorkeeper', '~> 4'

gem 'friendly_id'#, '~> 5.1.0'
gem 'ancestry'
gem 'pundit'
gem 'kaminari'
gem 'api-pagination'
gem 'geocoder'
gem 'countries'
gem 'ransack'
gem 'c_geohash', require: false
gem 'diffy', require: false
gem 'awesome_print', require: false
gem 'parallel', require: false

gem 'date_validator'
gem 'pg_search'
gem 'mailgun_rails'
gem 'dalli'
gem 'fast_blank'
gem 'oj', '2.18.3' # 3.0.0 breaks tests:  https://github.com/ohler55/oj/blob/master/CHANGELOG.md#300---2017-04-24
gem 'oj_mimic_json'
gem 'multi_json'

# Report errors to sentry.io
gem 'sentry-raven'

# eventMachine MQTT handler
gem 'em-mqtt'#, '~> 0.0.4'

group :production do
  gem 'rails_12factor'
end

group :test do
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'zonebie'
  gem 'codeclimate-test-reporter', require: nil
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'spring-commands-rspec'
  gem 'letter_opener'
  gem 'spring'
  gem 'sshkit'#, '1.7.1'
  gem 'sshkit-sudo'
  gem 'capistrano-rbenv'
  gem 'capistrano-sidekiq', github: 'seuros/capistrano-sidekiq'
  gem 'rubocop', require: false
  gem "parallel_tests"
  gem 'capistrano'#, '3.4.0'
  gem 'capistrano-rails'
  gem "rails-erd"
end

group :development, :test do
  # gem 'rspec_api_blueprint', require: false
  gem 'cane'
  gem 'faker'
  gem 'brakeman', github: 'presidentbeef/brakeman', require: false
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers',
    github: 'thoughtbot/shoulda-matchers', require: false,
    ref: '8e68d99217fac5dedceeeba226ea1f2d9be01e1b'
  gem 'guard-rspec'
  gem 'railroady'
  gem 'byebug'
  # gem 'web-console', '~> 2.0'
  gem 'rdoc'
end

group :development, :test, :linode do
  gem 'mysql'
end

# Deployment
gem 'unicorn'
