ruby '2.2.2'
source 'https://rubygems.org'

gem 'jbuilder'
gem 'responders'
gem 'newrelic_rpm'
# gem 'upsert'
# gem 'swagger-ui_rails'
# gem 'swagger-docs'
# gem 'prmd'
# gem 'keen'
gem 'rails', '4.2.3'
gem 'rails-api'
gem 'pusher'
gem 'pg'
gem 'bcrypt', '~> 3.1.7'
gem 'aws-sdk'

gem 'rack-timeout'
gem 'rack-attack' # API Rate Limiting
gem 'rack-cors', :require => 'rack/cors'
gem 'rack-contrib'

gem 'sidekiq'
# gem 'active_model_serializers', github: 'rails-api/active_model_serializers', branch: '0-8-stable'
gem 'oauth2', require: false
gem 'doorkeeper'
gem 'versionist'
# gem 'cassandra-driver'
# gem 'cequel', github: 'cequel/cequel'

gem 'friendly_id', '~> 5.1.0'
# gem 'msgpack'
gem 'ancestry'
gem 'pundit'
gem 'kaminari'
gem 'mailgun_rails'
gem 'api-pagination'
gem 'geocoder'
gem 'countries'
gem 'ransack'
gem 'c_geohash', require: false
gem 'date_validator'
gem 'pg_search'

# gem 'actionpack-action_caching', github: 'rails/actionpack-action_caching'

gem 'dalli'
gem 'redis-rails'
# gem 'redis-rack-cache'

gem 'fast_blank'
gem 'oj'
gem 'oj_mimic_json'
gem 'multi_json'

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
  gem 'railroady'
  gem 'spring-commands-rspec'
  gem 'letter_opener'
  gem 'spring'
  gem 'sshkit-sudo'
  gem 'capistrano-rbenv'
  gem 'capistrano-sidekiq', github: 'seuros/capistrano-sidekiq'
end

group :development, :test do
  # gem 'rspec_api_blueprint', require: false
  gem 'faker'
  gem 'figaro'
  gem 'brakeman', github: 'presidentbeef/brakeman', require: false
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers', require: false
  gem 'guard-rspec'
  gem 'railroady'
  gem 'mysql'
end


# gem 'byebug'
# gem 'web-console', '~> 2.0'

# Use unicorn as the app server
gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano-rails', :group => :development

