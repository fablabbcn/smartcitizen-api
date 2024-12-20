#!/bin/bash
set -Eeuo pipefail
git config --global --add safe.directory /app
bundle exec bin/rake db:create
bundle exec bin/rake db:schema:load
unset DATABASE_URL
bundle exec bin/rake spec
