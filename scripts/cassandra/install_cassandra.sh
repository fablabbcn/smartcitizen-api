#!/bin/sh
#
# based on https://stackoverflow.com/a/7755563
#
## Usage: install_cassandra.sh [options] CASSANDRA_VERSION
## 
## Where version X.Y.Z (ie. 2.1.10, 3.11.2, etc)
##
## Installs and configures cassandra on this server with recommended system settings
##
## Latest version numbers are available on https://cassandra.apache.org/download/
##
## Options:
##   -h, --help    Display this message.
##   -x, --disable-dry-run     By default script is run in dry-run mode, use this argument to disable dry-run
##

usage() {
  [ "$*" ] && echo "$0: $*"
  sed -n '/^##/,/^$/s/^## \{0,1\}//p' "$0"
  exit 2
} 2>/dev/null

parse_args() {
  while [ $# -gt 0 ]; do
    case $1 in
    (-x|--disable-dry-run) NO_DRY_RUN=1;;
    (-h|--help) usage 2>&1;;
    (--) shift; break;;
    (-*) usage "$1: unknown option";;
    (*) break;;
    esac
    shift
  done
  if [ $# != 1 ]; then
    echo "Wrong number of arguments: $#"
    usage
  fi
  CASSANDRA_VERSION=$1
  if [ ! $NO_DRY_RUN ]; then
    echo "WARNING: Running in dry-run mode. Execute with -x argument to execute commands"
  fi
}

# Run command if not in dry-run mode
run_cmd() {
  echo "Executing \"$*\""
  if [ $NO_DRY_RUN ]; then
    eval "$*"
  fi
}

INITIAL_PARAMS=$*
parse_args $*

# Need to run as root
if [ $USER != "root" ]; then
  echo "Script must be executed as root"
  exit 2
fi

# Check if environment file is present
if [ ! -f ".env" ]; then
  echo "Environment file \".env\" is not present. Make a copy of .env.example and adjust parameters."
  exit 2
fi

. ./.env

BASE_DIR="/opt"
DOWNLOAD_URL=http://archive.apache.org/dist/cassandra/$CASSANDRA_VERSION/apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz
TARBALL=`basename $DOWNLOAD_URL`
VERSION_DIR="$BASE_DIR/apache-cassandra-$CASSANDRA_VERSION"
CASSANDRA_DIR="$BASE_DIR/cassandra"

# Check if version is valid
curl -s --head $DOWNLOAD_URL | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null # from https://stackoverflow.com/a/2924444
if [ $? -ne 0 ]; then
  echo "ERROR: Version $CASSANDRA_VERSION is not valid or cannot download tarball from $DOWNLOAD_URL."
  exit 2
fi

# Check if cassandra is already installed
if [ -d $VERSION_DIR ]; then
  echo "ERROR: version $CASSANDRA_VERSION is already installed."
  exit 2
fi

# Check if environment file is present
if [ ! -f ".env" ]; then
  echo "Environment file \".env\" is not present. Make a copy of env.example and adjust parameters."
  exit 2
fi

echo "Installing cassandra $CASSANDRA_VERSION on $VERSION_DIR"

# Download tarball
run_cmd "wget $DOWNLOAD_URL"

# Unpack tarball
run_cmd "tar xvzf $TARBALL -C $BASE_DIR"

# Make /opt/cassandra point to the current version
run_cmd "ln -snf $VERSION_DIR $CASSANDRA_DIR"

# Fix cassandra logdir to use $CASSANDRA_LOG_DIR variable (necessary on 2.X series)
run_cmd "sed -i 's/\$CASSANDRA_HOME\/logs/\$CASSANDRA_LOG_DIR/' $CASSANDRA_DIR/bin/cassandra"

# Set CASSANDRA_HOME and CASSANDRA_CONF on /opt/cassandra/cassandra.in.sh
run_cmd "sed '/.*limitations under the License.*/a CASSANDRA_HOME=$CASSANDRA_DIR\nCASSANDRA_CONF=$CASSANDRA_DIR/conf\nCASSANDRA_LOG_DIR=$LOG_DIR' \
$CASSANDRA_DIR/bin/cassandra.in.sh > $CASSANDRA_DIR/cassandra.in.sh"

# Set cassandra storage dir
ESCAPED_STORAGE_DIR=`echo $STORAGE_DIR| sed 's/\//\\\\\//g'`
run_cmd "sed -i 's/cassandra_storagedir=.*/cassandra_storagedir=\"$ESCAPED_STORAGE_DIR\"/g' $CASSANDRA_DIR/cassandra.in.sh"

# Remove tarball
run_cmd "rm $TARBALL"

# If the cassandra user exists, means cassandra was installed previously, no need to perform system configuration below.
if id -u cassandra > /dev/null 2>&1; then
  echo "Cassandra installed, will now configure."
  ./configure_cassandra.sh $INITIAL_PARAMS
  exit 0
fi

# System configuration (only on first install)

# Install dependecies (From https://cassandra.apache.org/doc/latest/getting_started/installing.html)
run_cmd "apt install -y openjdk-8-jdk"
run_cmd "apt install -y ntp"
run_cmd "apt install -y python2"
run_cmd "ln -snf /usr/bin/python2 /usr/bin/python"

# Add cassandra user if it does not exist
run_cmd "useradd cassandra"

# Install nodetool on /usr/local/bin
run_cmd "ln -snf $CASSANDRA_DIR/bin/nodetool /usr/local/bin/nodetool"

# Install cqlsh on /usr/local/bin
run_cmd "ln -snf $CASSANDRA_DIR/bin/cqlsh /usr/local/bin/cqlsh"

# Create storage and log dirs and make cassandra user own them
run_cmd "mkdir -p $STORAGE_DIR"
run_cmd "mkdir -p $LOG_DIR"
run_cmd "chown -R cassandra:cassandra $STORAGE_DIR"
run_cmd "chown -R cassandra:cassandra $LOG_DIR"

# Recommended production settings (from https://docs.datastax.com/en/cassandra-oss/3.0/cassandra/install/installRecommendSettings.html)

# Apply sysctl settings
run_cmd "cp cassandra-sysctl.conf /etc/sysctl.d/"
run_cmd "sysctl -p"

# Disable swap
run_cmd "swapoff --all"
run_cmd "sed -i '/swap/d' /etc/fstab"

# Install cassandra service
run_cmd "cp cassandra-settings.service /usr/lib/systemd/system/"
run_cmd "cp cassandra.service /usr/lib/systemd/system/"
run_cmd "systemctl daemon-reload"
run_cmd "systemctl start cassandra-settings.service"
run_cmd "systemctl enable cassandra-settings.service"

echo "Cassandra installed, will now configure"
./configure_cassandra.sh $INITIAL_PARAMS

echo "Cassandra $CASSANDRA_VERSION successfully installed and configured. A reboot is required to apply all system changes."
