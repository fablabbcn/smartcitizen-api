#!/bin/bash
if ! [[ $1 ]]; then
  echo "Database name missing for BACKUP."
  echo "Usage: 'docker_backup_db.sh my_db_name'"
  exit
fi

docker exec -i $(docker-compose ps -q db) pg_dump -Upostgres $1 > dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql
