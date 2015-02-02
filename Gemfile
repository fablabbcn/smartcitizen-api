ruby '2.2.0'
source 'https://rubygems.org'

gem 'rails', '4.2.0'
gem 'rails-api'
gem 'pg'
gem 'bcrypt', '~> 3.1.7'
gem 'active_model_serializers', github: 'rails-api/active_model_serializers', branch: '0-9-stable'
gem 'oauth2', require: false
gem 'doorkeeper'
gem 'versionist'
gem 'cassandra-driver', require: false
gem 'cequel', github: 'cequel/cequel'
gem 'rack-attack' # API Rate Limiting
gem 'friendly_id', '~> 5.1.0'
gem 'msgpack'
gem 'ancestry'
gem 'pundit'
gem 'kaminari'
gem 'mailgun_rails'
gem 'api-pagination'
gem 'geocoder'
gem 'ransack'
gem 'c_geohash', require: false

gem 'fast_blank'
gem 'oj'
gem 'oj_mimic_json'

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
end

group :development, :test do
  gem 'rspec_api_blueprint', require: false
  gem 'ffaker'
  gem 'figaro'
  gem 'spring'
  gem 'brakeman', github: 'presidentbeef/brakeman', require: false
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers', require: false, github: 'thoughtbot/shoulda-matchers'
  gem 'guard-rspec'
end


# gem 'byebug'
# gem 'web-console', '~> 2.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', :group => :development

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
