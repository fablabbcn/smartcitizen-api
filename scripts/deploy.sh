#!/bin/sh
git pull origin master;
docker-compose pull auth;
docker-compose build && docker-compose up -d
