# BACKUP
docker exec -i $(docker-compose ps -q db) psql -Upostgres  < dump_latest.sql
#docker-compose exec -T db pg_dump -hlocalhost -U postgres sc_dev > dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql
