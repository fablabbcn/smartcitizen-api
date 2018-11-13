#!/bin/sh
git pull origin master;
docker-compose build && docker-compose up -d
