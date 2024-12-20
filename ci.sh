#!/bin/bash
set -e
bundle exec bin/rake db:create
bundle exec bin/rake db:schema:load
unset DATABASE_URL
bundle exec bin/rake spec
