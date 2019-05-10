# RESTORE
#docker exec -i smartcitizenapi_db_1 psql -Upostgres  < dump_latest.sql
docker-compose exec -T db psql -Upostgres -d sc_dev < dump_latest.sql
