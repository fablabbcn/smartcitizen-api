#!/bin/bash
git config --global --add safe.directory /app
unset DATABASE_URL
source $NVM_DIR/nvm.sh
bundle exec bin/rake spec
