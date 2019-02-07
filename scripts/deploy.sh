#!/bin/sh
# Always pull from master? What if staging should deploy 'dev' branch?
git pull origin master;
docker-compose pull auth push;
# Accept containers as params. Supports starting only 'app db' f.x.
docker-compose build && docker-compose up -d $@

# Do we want to auto migrate?
# For now, we only check if migration is needed
docker-compose exec app rake db:migrate:status
#docker-compose exec app rake db:migrate

date >> deploy_history.txt
git rev-parse HEAD >> deploy_history.txt
