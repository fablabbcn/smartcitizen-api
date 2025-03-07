#!/bin/bash
set -ae
git config --global --add safe.directory /app
source $NVM_DIR/nvm.sh
nvm use default
yarn install
NODE_OPTIONS=--openssl-legacy-provider bundle exec bin/rake assets:precompile
bundle exec bin/rake db:create
bundle exec bin/rake db:schema:load
unset DATABASE_URL
RAILS_ENV=test bundle exec bin/rake db:create
RAILS_ENV=test bundle exec bin/rake db:schema:load
bundle exec bin/rake spec
