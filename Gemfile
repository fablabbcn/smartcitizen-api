ruby '2.2.2'
source 'https://rubygems.org'

gem 'rails', '4.2.4'
gem 'rails-api'

gem 'rack-timeout'
# gem 'rack-attack' # API Rate Limiting
gem 'rack-cors', :require => 'rack/cors'
gem 'rack-contrib'
gem 'rack-cache'
# gem 'actionpack-page_caching'
# gem 'actionpack-action_caching'

# https://github.com/guard/listen/wiki/Duplicate-directory-errors
# prevent 2.8 and greater from being used
gem 'listen'#, '~> 2.7.12'
gem 'airbrake'

gem 'statsample'
gem 'pg'
# gem 'upsert'
gem 'parallel', require: false

gem 'lograge'

gem 'figaro'
gem 'versionist', github: 'bploetz/versionist'
gem 'jbuilder'
gem 'responders'
gem 'newrelic_rpm'
gem 'pusher'
gem 'workflow'

gem 'bcrypt', '~> 3.1.7'
gem 'aws-sdk'

gem 'redis-rails'
gem 'sidekiq'

gem 'oauth2', require: false
gem 'doorkeeper'

gem 'friendly_id', '~> 5.1.0'
gem 'ancestry'
gem 'pundit'
gem 'kaminari'
gem 'api-pagination'
gem 'geocoder'
gem 'countries', github: 'hexorx/countries'
gem 'ransack'
gem 'c_geohash', require: false
gem 'date_validator'
gem 'pg_search'

gem 'mailgun_rails'

gem 'dalli'

gem 'fast_blank'
gem 'oj'
gem 'oj_mimic_json'
gem 'multi_json'
# gem 'charlock_holmes'

group :production do
  gem 'rails_12factor'
end

group :test do
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'zonebie'
  gem "codeclimate-test-reporter", require: nil
  gem "timecop"
end

group :development do
  gem 'quiet_assets'
  gem 'spring-commands-rspec'
  gem 'letter_opener'
  gem 'spring'
  gem 'sshkit-sudo'
  gem 'capistrano-rbenv'
  gem 'capistrano-sidekiq', github: 'seuros/capistrano-sidekiq', ref: '8d8d9317b6f5862d86c800ba56a5e406be24b2c1'
end

group :development, :test do
  # gem 'rspec_api_blueprint', require: false
  gem 'cane'
  gem 'faker'
  gem 'brakeman', github: 'presidentbeef/brakeman', require: false
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers', require: false
  gem 'guard-rspec'
  gem 'railroady'
  # gem 'byebug'
  # gem 'web-console', '~> 2.0'
end

group :development, :test, :linode do
  gem 'mysql'
end

# Deployment
gem 'unicorn'
gem 'capistrano-rails', :group => :development
