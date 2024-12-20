#!/bin/bash

set -e
source $NVM_DIR/nvm.sh
unset DATABASE_URL
bundle exec bin/rake spec
