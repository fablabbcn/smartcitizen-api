# RESTORE
docker exec -i $(docker-compose ps -q db) psql -Upostgres  < dump_latest.sql
#docker-compose exec -T db psql -Upostgres -d sc_dev < dump_latest.sql
