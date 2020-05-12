Cassandra Operation
=================

   * [Installing cassandra](#installing-cassandra)
   * [Configuring cassandra](#configuring-cassandra)
   * [Starting and stopping cassandra](#starting-and-stopping-cassandra)
      * [Starting Cassandra](#starting-cassandra)
      * [Stopping Cassandra](#stopping-cassandra)
      * [Enabling cassandra service to auto-start on boot](#enabling-cassandra-service-to-auto-start-on-boot)
   * [Adding a new cassandra node](#adding-a-new-cassandra-node)
   * [Migrating cassandra to another host](#migrating-cassandra-to-another-host)
   * [Upgrading Cassandra](#upgrading-cassandra)
      * [Before the upgrade](#before-the-upgrade)
      * [Minor upgrade](#minor-upgrade)
      * [Major upgrade](#major-upgrade)
         * [Testing the upgrade](#testing-the-upgrade)
         * [Performing the major upgrade](#performing-the-major-upgrade)
      * [Rollback from upgrade](#rollback-from-upgrade)
      * [After the uprade](#after-the-uprade)
   * [Backup &amp; Restore](#backup--restore)
      * [Backup](#backup)
      * [Restore](#restore)
   * [Repair data after node failure or backup recovery](#repair-data-after-node-failure-or-backup-recovery)

# Installing cassandra

1. Copy the sample `env.example` file to `.env` and edit variables with the proper configuration for this node:

   `cp env.example .env`

2. Install cassandra version `X.Y.Z` with the following command:

   `./install_cassandra.sh X.Y.Z`

   By default this script runs in dry-run mode so you can double check the install and configuration commands.
   Use the -x flag (ie. `./install_cassandra.sh -x X.Y.Z`) to perform the actual installation.

Cassandra is installed on the `/opt/apache-cassandra-X.Y.Z` directory. A symlink is created from `/opt/cassandra`
to `/opt/apache-cassandra-X.Y.Z`. The cassandra service is installed on systemctl and is disabled by default. 
The nodetool and cqlsh commands are placed on `/usr/local/bin`.

The following variables are set during install:
   * CASSANDRA\_HOME=/opt/cassandra
   * CASSANDRA\_CONF=/opt/cassandra/conf
   * CASSANDRA\_LOG\_DIR=/var/log/cassandra
   * cassandra\_storagedir=/var/lib/cassandra

This installation is targeted at Ubuntu systems and was tested with Ubuntu 20.04.

# Configuring cassandra

The installation script will automatically configure cassandra according to the parameters specified on the `.env` file.
If any changes need to be made in the configuration after the `.env` file is updated, run the following command:

   `./configure-cassandra -x`

Please note the `-x` flag must be specified, otherwise the script will be run in dry-run mode.

The important parameters to specify are CLUSTER\_NAME, SEEDS, LISTEN\_ADDRESS, RPC\_ADDRESS.

Please note that any parameters manually specified on /opt/cassandra/conf/cassandra.yaml may be lost when this script is
run so it's important to update the script to take into account new parameters.

# Starting and stopping cassandra

## Starting Cassandra

Start the cassandra service with:

  `sudo service cassandra start`

Check that cassandra was started without errors by inspecting the log on `/var/log/cassandra/system.log`.

## Stopping Cassandra

Before stopping cassandra, it's recommended to drain the node so all data is flushed to disk with:

  `nodetool drain`

After the node is drain stop the cassandra service with:

  `sudo service cassandra stop`

## Enabling cassandra service to auto-start on boot

Use the following command to configure the node to automatically start cassandra if the node is restarted:

  `sudo systemctl enable cassandra.service`

# Adding a new cassandra node

New nodes must be added when there are performance issues on the cluster or when the disk capacity reaches around 75%.
In order to add a new node just install cassandra according to the instructions above and make sure to set the 
CLUSTER\_NAME and SEEDS to point to the cluster where you want the new node to join.

# Migrating cassandra to another host

1. Install and configure the desired version of cassandra in the new server with:

  `./install_cassandra.sh -x <version>`.

  Make sure the new server IP is configured on the `.env` file.

2. Create the storage directory `/var/lib/cassandra` on the new host with:

  `mkdir -p /var/lib/cassandra`

3. On the new host, copy the data directory from the old host with rsync:

  `rsync -aczP --stats user@old_host:/var/lib/cassandra/data /var/lib/cassandra/`

5. Drain and stop the original cassandra node being migrated:

  ```
  nodetool drain
  service cassandra stop
  ```

6. Run rsync again on the new host so the remaining data is copied over:

  `rsync -aczP --stats user@old_host:/var/lib/cassandra/data /var/lib/cassandra/`

7. Make sure the newly copied data is owned by the `cassandra` user:

  `chown -R cassandra:cassandra /var/lib/cassandra/`

8. Start cassandra on the new host with:

  `service cassandra start`

9. Check that the system logs for any errors during startup:

  `tail -f /var/log/cassandra/system.log`

10. Check that the migrated node IP is seen by other hosts with:

   `nodetool status` 

# Upgrading Cassandra

## Before the upgrade

It's recommended to perform a snapshot of the all tables before doing the upgrade as a precaution step in case something goes wrong during the upgrade:

  `nodetool snapshot`

This will create a snapshot on `/var/lib/cassandra/data/<table>/snapshots/<snapshot_id>`.

## Minor upgrade

Performing an upgrade on Cassandra between patch versions is very simple (ie. from version 3.11.2 to 3.11.7).
The upgrade must be performed in a rolling-restart manner one node at a time with the following steps on each node:

1. Drain and stop cassandra:

  ```
  nodetool drain
  service cassandra stop
  ```

2. Install the new cassandra version with:

  `./install_cassandra.sh <version>`

3. Start the cassandra process on the new version:

  `service cassandra start`

4. Check logs and application to verify everything is running correctly before upgrading the next node.

## Major upgrade

### Testing the upgrade

Since there can be changes in the data format between major versions, it is recommended to test the upgrade in a separate node
before performing an upgrade between major versions (ie. from 3.11 to 4.0). Peform the following steps to test a major upgrade:

1. Install and configure the desired version of cassandra in the new server with:

  `./install_cassandra.sh -x <version>`.

  Make sure the new server has a different CLUSTER\_NAME specified on the .env file
  so it doesn't accidentaly join the old cluster.

2. Export the kairosdb schema from a running node:

  `cqlsh -u USER -p PASS -e "DESC KEYSPACE kairosdb" NODE_IP > kairosdb_schema.cql`

3. Start cassandra on the new node with:

  `service cassandra start`

4. Import the created schema by entering cqlsh and use the following command:

  ```
  cqlsh -u USER -p PASS NODE_IP
  SOURCE 'kairosdb_schema.cql'
  ```

5. Stop the cassandra node:

  `service cassandra stop`

6. Copy the kairosdb data files from a node in the previous version: 

  `rsync -aczP --stats user@old_host:/var/lib/cassandra/data/kairosdb/ /var/lib/cassandra/data/kairosdb`

5. Start the cassandra service:

  `service cassandra start`

7. Perform some queries via cqlsh or point the staging applicaton to this cassandra server and verify
   the data is being read correctly without errors.

### Performing the major upgrade

The steps are the same for performing a minor upgrade, except that after the upgrade is completed
you must run the following command after the upgrade on each node (before moving to next):

  `nodetool upgradesstables`

This command will ensure data files are upgaded to the newer version and may take a while to run.

## Rollback from upgrade

Failed upgrades are very unlikely, but in case it happens, perform the following steps to rollback a node:

1. Stop cassandra server that was upgraded:

  `service cassandra stop`

2. Restore the old version with:

  `ln -snf /opt/apache-cassandra-<old-version> /opt/cassandra`

3. Replace all the data from `/var/lib/cassandra/data/<table>` with `/var/lib/cassandra/data/<table>/snapshots/<snapshot_id>` for all tables.

4. Clean all data from `/var/lib/cassandra/data/commitlogs`, `/var/lib/cassandra/data/hints` and `/var/lib/cassandra/data/saved_caches`.

5. Start cassandra

  `service cassandra start`

## After the uprade

If everything goes well with the upgrade, don't forget to clean the snapshot files with:

  `nodetool clearsnapshot`

# Backup & Restore

## Backup

The simplest way to backup a cassandra node is to use the cloud provider's VM snapshot feature.

## Restore

After restoring the snapshot VM from your cloud provider, you need to update the node's IP address
on the `.env` file on `LISTEN_ADDRESS`, `RPC_ADDRESS` and `SEEDS` and run the following command:

  `./configure_cassandra.sh -x`

After that start the cassandra process with:

  `service cassandra start`

After restoring the node from backup it's recommended to run repair (as instructed below).

# Repair data after node failure or backup recovery

If a node is down for longer than 3 hours (max\_hint\_window\_in\_ms), run the following command to
make the node synchronize data with other nodes in the cluster:

  `./repair_node.sh USERNAME PASSWORD NODE_PRIVATE_IP`
