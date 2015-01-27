ruby '2.2.0'
source 'https://rubygems.org'

gem 'rails', '4.2.0'
gem 'rails-api'
gem 'bcrypt', '~> 3.1.7'
gem 'active_model_serializers', github: 'rails-api/active_model_serializers', branch: '0-9-stable'
gem 'oauth2', require: false
gem 'doorkeeper'
gem 'versionist'
gem 'pg'
gem 'cassandra-driver', require: false
gem 'cequel', github: 'cequel/cequel'

group :production do
  gem 'rails_12factor'
end

group :test do
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'zonebie'
  gem "codeclimate-test-reporter", require: nil
end

group :development do
  gem 'quiet_assets'
  gem 'spring-commands-rspec'
  gem 'letter_opener'
end

group :development, :test do
  gem 'ffaker'
  gem 'figaro'
  gem 'spring'
  gem 'brakeman', github: 'presidentbeef/brakeman', require: false
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers', require: false
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