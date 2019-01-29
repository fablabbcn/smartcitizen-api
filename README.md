# SmartCitizen API [![Build Status](https://travis-ci.org/fablabbcn/smartcitizen-api.svg?branch=master)](https://travis-ci.org/fablabbcn/smartcitizen-api)
[![Maintainability](https://api.codeclimate.com/v1/badges/2ac767745186038373f5/maintainability)](https://codeclimate.com/github/fablabbcn/smartcitizen-api/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/2ac767745186038373f5/test_coverage)](https://codeclimate.com/github/fablabbcn/smartcitizen-api/test_coverage)

### [Documentation](https://developer.smartcitizen.me)

* Production API - [https://api.smartcitizen.me](https://api.smartcitizen.me)
* Basic Map Example - [https://api.smartcitizen.me/examples/map](https://api.smartcitizen.me/examples/map) ([map](https://github.com/fablabbcn/smartcitizen/blob/master/public/examples/map.html))
* OAuth 2.0 (Implicit Grant) Example - [http://example.smartcitizen.me](http://example.smartcitizen.me) ([smartcitizen-oauth-example](https://github.com/fablabbcn/smartcitizen-oauth-example))

## Installing Locally

### Docker quickstart

1. Copy the environment file, and edit variables, domain name, etc

   `cp env.example .env`

2. Start basic services (recommended)

   In a new terminal window do:
   
   `docker-compose up app db`

   See the `docker-compose.yml` file `depends_on:` section to see which containers depend on which.

   Available containers:

   * `app` - Rails app
   * `db` - Postgres
   * `redis`
   * `web` container which tries to get a certificate with Lets Encrypt.
   * `mqtt` EMQ + management interface on http://localhost:18083 *admin:public*
   * `mqtt-task` a rake task which subscribes to the `mqtt` service
   * `sidekiq`
   * `kairos` - Time series database on Cassandra
   * `cassandra-1` - Stores the data

   Start ALL of them (not recommended) with:

   `docker-compose up`

3. (OPTIONAL) Start Cassandra cluster of 3 nodes

   If you want to start Kairos with 3 Cassandra cluster with 3 nodes:

   * Uncomment the other 2 cassandras in `docker-compose.yml` file

   * Edit the file `scripts/conf/kairosdb.properties` and change the following line:

     `kairosdb.datastore.cassandra.cql_host_list=cassandra-1`

     `docker-compose up kairos cassandra-1 cassandra-2 cassandra-3`


4. Create the database (first time only)

   If you need to perfom many operations, it is better to `bash` into the container:

   `docker-compose exec app bash` 

   and from here you can do

   `rails db:create`
  
   `rails db:schema:load` 
  
   `rails db:seed`

    Note: These 3 commands are the same as: `docker-compose exec app rails db:setup` **but is not working ATM!** due to some weird bug.

5. Removing everything

  Remove all containers + data volumes with:

  `docker-compose down -v` 

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

`get config/application.yml (check production server or contact webmasters@smartcitizen.me)`

`bundle install`

`bundle exec rails s`

## Deploying

First get the `config/application.yml` env vars from the production machine.

### Using Docker

  1. SSH into the server
  2. `git pull`
  2. `docker-compose build`
  2. `docker-compose up -d`

### Using Capistrano (not used with Docker)
`bundle exec cap production deploy` < password currently required. **Don't run this without discussing in Slack or issues first**. We will be automating deployments with CI/Travis so this command will eventually be deprecated.

`bundle exec cap production deploy:setup_config` < deploy configuration (symlinks to nginx, monit, etc..)

If you need to restart Sidekiq:

`bundle exec cap production sidekiq:restart`


## Working with MQTT and WebSockets

If running on Docker, there should be a EMQ Dashboard running on http://localhost:18083 (Log in with **admin:public**)

The following will send a message from the `app` container to the `mqtt` container:

1. Subscribe to a Websocket topic called "test" in the Dashboard http://localhost:18083/#/websocket

2. Access the rails console inside the `app` container:

  `docker-compose exec app rails console`

3. Send a message to the `test` topic:

  `MQTT::Client.connect('mqtt').publish('test', 'this is the message')`


## Tools / Scripts

We supply a nodejs helper `post-readings.js` tool to test sending massive amounts of data. Just like uploading a CSV file with a lot of readings.

To learn how to use it, do `./post-readings.js`

## Versioning

Currently using this tool to manually handle versioning: https://github.com/gregorym/bump

Use this command to update the VERSION file + create a git tag

`bump patch --tag`

Then push the git tag with:

`git push --tags`
