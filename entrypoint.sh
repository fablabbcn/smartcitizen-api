#!/bin/bash
set -e
echo $NVM_DIR
echo `ls $NVM_DIR`
source $NVM_DIR/nvm.sh

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid


# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
