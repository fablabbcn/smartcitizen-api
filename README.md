# SmartCitizen

[![Build Status](https://travis-ci.org/fablabbcn/smartcitizen.svg?branch=master)](https://travis-ci.org/fablabbcn/smartcitizen)
[![Code Climate](https://codeclimate.com/github/fablabbcn/smartcitizen/badges/gpa.svg)](https://codeclimate.com/github/fablabbcn/smartcitizen)
[![Test Coverage](https://codeclimate.com/github/fablabbcn/smartcitizen/badges/coverage.svg)](https://codeclimate.com/github/fablabbcn/smartcitizen)

### [Documentation](https://developer.smartcitizen.me)

* Production API - [https://api.smartcitizen.me](https://api.smartcitizen.me)
* Errors - [https://errors.smartcitizen.me](https://errors.smartcitizen.me)
* Basic Map Example - [https://api.smartcitizen.me/examples/map](https://api.smartcitizen.me/examples/map) ([map](https://github.com/fablabbcn/smartcitizen/blob/master/public/examples/map.html))
* OAuth 2.0 (Implicit Grant) Example - [http://example.smartcitizen.me](http://example.smartcitizen.me) ([smartcitizen-oauth-example](https://github.com/fablabbcn/smartcitizen-oauth-example))

## Installing Locally

### Docker quickstart

1. Start all services

`docker-compose up`

2. Create the database (first time only)
`docker-compose exec app rake db:setup`

### Linux (Tested on Ubuntu 16.04)

`apt-get install libmysqlclient-dev`

### Redis and Postgresql

`brew tap homebrew/services`

`brew install redis postgresql`

`brew services start redis`

`brew services start postgresql`

### KairosDB

`wget https://github.com/kairosdb/kairosdb/releases/download/v1.0.0/kairosdb-1.0.0-1.tar.gz`

`tar -zxvf kairosdb-1.0.0-1.tar.gz`

`./kairosdb/bin/kairosdb.sh run`

### SmartCitizen

`git clone https://github.com/fablabbcn/smartcitizen`

`cd smartcitizen`

`get config/application.yml and config/banned_words.production.yml (check production server or contact john@bitsushi.com)`

`bundle install`

`bundle exec rails s`

### Deploying

First get the config/application.yml env vars from the production machine.

`bundle exec cap production deploy` < password currently required. *Don't run this without discussing in slack or issues first*. We will be automating deployments with CI/Travis so this command will eventually be deprecated.

`bundle exec cap production deploy:setup_config` < deploy configuration (symlinks to nginx, monit, etc..)

### Useful commands

`bundle exec cap production sidekiq:restart` < if sidekiq has a memory leak or something
