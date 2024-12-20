#!/bin/bash
set -Eeuo pipefail
git config --global --add safe.directory /app
unset DATABASE_URL
bundle exec bin/rake spec
