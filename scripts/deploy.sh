#!/bin/sh
# Always pull from master? What if staging should deploy 'dev' branch?
git pull origin master;
docker compose pull auth;
# Accept containers as params. Supports starting only 'app db' f.x.
docker compose build && docker compose up -d $@

# Do we want to auto migrate?
# For now, we only check if migration is needed
docker compose exec app bin/rails db:migrate:status
#docker compose exec app bin/rails db:migrate

echo $(date) $(git rev-parse HEAD) >> deploy_history.txt
