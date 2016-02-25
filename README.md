# SmartCitizen

[![Build Status](https://travis-ci.org/fablabbcn/smartcitizen.svg?branch=master)](https://travis-ci.org/fablabbcn/smartcitizen)
[![Code Climate](https://codeclimate.com/github/fablabbcn/smartcitizen/badges/gpa.svg)](https://codeclimate.com/github/fablabbcn/smartcitizen)
[![Test Coverage](https://codeclimate.com/github/fablabbcn/smartcitizen/badges/coverage.svg)](https://codeclimate.com/github/fablabbcn/smartcitizen)

### [Documentation](https://developer.smartcitizen.me)

* API - [https://api.smartcitizen.me](https://api.smartcitizen.me)
* Map Example - [https://api.smartcitizen.me/examples/map](https://api.smartcitizen.me/examples/map) ([map](https://github.com/fablabbcn/smartcitizen/blob/master/public/examples/map.html))
* Login Page - [https://id.smartcitizen.me](https://id.smartcitizen.me) ([smartcitizen-auth](https://github.com/fablabbcn/smartcitizen-auth))
* OAuth Example - [http://example.smartcitizen.me](http://example.smartcitizen.me) ([smartcitizen-oauth-example](https://github.com/fablabbcn/smartcitizen-oauth-example))

## Installing Locally (incomplete)

### Redis and Postgresql

`brew tap homebrew/services`

`brew install redis postgresql`

`brew services start redis`

`brew services start postgresql`

### KairosDB

`wget https://github.com/kairosdb/kairosdb/releases/download/v1.0.0/kairosdb-1.0.0-1.tar.gz`

`tar -zxvf kairosdb-1.0.0-1.tar.gz`

`./kairosdb/bin/kairosdb.sh run`

### SmartCitizen

`git clone https://github.com/fablabbcn/smartcitizen`

`cd smartcitizen`

`bundle install`

`bundle exec rails s`
