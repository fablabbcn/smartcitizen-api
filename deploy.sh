#!/bin/bash
#git stash
#git pull --rebase
#git stash pop
docker compose build
docker compose exec app bundle exec bin/rake db:migrate
docker compose exec app bash -l -c "bundle exec yarn install"
docker compose exec app bash -l -c "bundle exec bin/rake assets:clobber"
docker compose exec app bash -l -c "NODE_OPTIONS=--openssl-legacy-provider bundle exec bin/rake assets:precompile"
docker compose up -d
