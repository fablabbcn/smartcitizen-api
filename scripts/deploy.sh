#!/bin/sh
git pull origin master;
docker-compose pull auth push;
docker-compose build && docker-compose up -d
