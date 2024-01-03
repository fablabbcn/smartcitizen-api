# SmartCitizen API

![](https://github.com/fablabbcn/smartcitizen-api/workflows/Ruby/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/2ac767745186038373f5/maintainability)](https://codeclimate.com/github/fablabbcn/smartcitizen-api/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/2ac767745186038373f5/test_coverage)](https://codeclimate.com/github/fablabbcn/smartcitizen-api/test_coverage)
[![DOI](https://zenodo.org/badge/29865657.svg)](https://zenodo.org/badge/latestdoi/29865657)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)]()

## [Documentation](https://developer.smartcitizen.me)

* Production API - [https://api.smartcitizen.me](https://api.smartcitizen.me)
* Basic Map Example - [https://api.smartcitizen.me/examples/map](https://api.smartcitizen.me/examples/map) ([map](https://github.com/fablabbcn/smartcitizen/blob/master/public/examples/map.html))
* OAuth 2.0 (Implicit Grant) Example - [http://example.smartcitizen.me](http://example.smartcitizen.me) ([smartcitizen-oauth-example](https://github.com/fablabbcn/smartcitizen-oauth-example))

## Installing Locally

To get the whole environment up locally (without Docker), you need to install and configure multiple technologies like:
- Ruby on Rails
- Postgres
- Redis
- Kairos
- Cassandra
- Nodejs

It is complex, that is why we recommend using Docker.

For developing a feature, you really only need Ruby on Rails and Postgres.
We recommend using `rbenv`.

### Docker quickstart

1. Copy the environment file, and edit variables, domain name, etc

   `cp env.example .env`

2. Copy the local development docker overrides:
   `cp compose.override.local.yml compose.override.yml`

3. Start basic services (recommended)

   In a new terminal window do:

   `docker compose up app db`

   See the `compose.yml` file `depends_on:` section to see which containers depend on which.

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

   `docker compose up`

4. (OPTIONAL) Start Cassandra cluster of 3 nodes

   If you want to start Kairos with 3 Cassandra cluster with 3 nodes:

   * Uncomment the other 2 cassandras in `compose.yml` file

   * Edit the file `scripts/conf/kairosdb.properties` and change the following line:

     `kairosdb.datastore.cassandra.cql_host_list=cassandra-1`

     `docker compose up kairos cassandra-1 cassandra-2 cassandra-3`

5. Create the database (first time only)

   If you need to perfom many operations, it might be better to `bash` into the container:

   `docker compose exec app bash`

   and from here you can do

   `bin/rails db:create`

   `bin/rails db:schema:load`

   `bin/rails db:seed`

    Or you can run them all at once with: `docker compose exec app bin/rails db:setup`

6. Removing everything

   Remove all containers + data volumes with:

   `docker compose down -v`

## Running the tests on a local docker container:

_(I'm not 100% clear why step (3) is needed, but for some reason the DATABASE_URL overrides the test database details in database.yml which causes problems)_

1. Make sure you're running the app and db containers as above:
   `docker compose up app db`

2. In another terminal, get a shell within the app container:
   `docker compose exec app bash`

3. Within that shell, unset the DATABASE_URL environment variable:
   `unset DATABASE_URL`

4. Finally, run the tests (within that shell)!
   `bundle exec bin/rake spec`

## Deploying

### Using Docker

1. SSH into the server
1. `git pull`
1. `docker compose build`
1. `docker compose up -d`

## Cassandra

Documentation and scripts to deploy and operate cassandra in
production are available on [scripts/cassandra](scripts/cassandra).

## Backup and restore

In the scripts/ folder there are backup and restore scripts for docker postgres.

## Tools and scripts

We supply a nodejs helper `post-readings.js` tool to test sending massive amounts of data. Just like uploading a CSV file with a lot of readings.

To learn how to use it, do `scripts/dev-tools/post-readings.js`

You can also read more about the platform on [docs/](docs/)

## Versioning

Currently using this tool to manually handle versioning: https://github.com/gregorym/bump

Use this command to update the VERSION file + create a git tag

`bump patch --tag`

Then push the git tag with:

`git push --tags`

## Funding

This work has received funding from the European Union's Horizon 2020 research and innovation program under the grant agreement [No. 689954](https://cordis.europa.eu/project/rcn/202639_en.html)
