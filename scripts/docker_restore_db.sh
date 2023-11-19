#!/bin/bash
if ! [[ $1 ]]; then
  echo "Database name missing for RESTORE."
  echo "Usage: 'docker_restore_db.sh my_db_name'"
  exit
fi

docker exec -i $(docker compose ps -q db) psql -Upostgres $1  < dump_latest.sql
