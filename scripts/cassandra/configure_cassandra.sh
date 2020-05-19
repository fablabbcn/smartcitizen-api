#!/bin/sh
#
# based on https://stackoverflow.com/a/7755563
#
## Usage: install_cassandra.sh
## 
## Configures cassandra on this server according to the configuration defined on the .env file
##
## Options:
##   -h, --help    Display this message.
##   -x, --disable-dry-run     By default script is run in dry-run mode, use this argument to disable dry-run
##   -c, --conf-dir     Cassandra configuration directory (by default /opt/cassandra/conf)
##

usage() {
  [ "$*" ] && echo "$0: $*"
  sed -n '/^##/,/^$/s/^## \{0,1\}//p' "$0"
  exit 2
} 2>/dev/null

parse_args() {
  CONF_DIR=/opt/cassandra/conf
  while [ $# -gt 0 ]; do
    case $1 in
    (-x|--disable-dry-run) NO_DRY_RUN=1;;
    (-c|--conf-dir) shift; CONF_DIR=$1;;
    (-h|--help) usage 2>&1;;
    (--) shift; break;;
    (-*) usage "$1: unknown option";;
    (*) break;;
    esac
    shift
  done
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

check_non_empty() {
  VAR_NAME=$1
  VAR_VALUE=$2
  if [ -z $VAR_VALUE ]; then
    echo "ERROR: Required variable $VAR_NAME is undefined on .env file"
    exit 2
  fi
}

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

if [ ! -d $CONF_DIR ]; then
  echo "ERROR: Cassandra configuration directory not found at $CONF_DIR."
  exit 2
fi

# Set cluster name
check_non_empty CLUSTER_NAME $CLUSTER_NAME
run_cmd "sed -i 's/cluster_name:.*/cluster_name: $CLUSTER_NAME/g' $CONF_DIR/cassandra.yaml"

# Set seeds
check_non_empty SEEDS $SEEDS
run_cmd "sed -i 's/- seeds:.*/- seeds: \"$SEEDS\"/g' $CONF_DIR/cassandra.yaml"

# Set listen_address
check_non_empty LISTEN_ADDRESS $LISTEN_ADDRESS
run_cmd "sed -i 's/listen_address:.*/listen_address: $LISTEN_ADDRESS/g' $CONF_DIR/cassandra.yaml"

# Set rpc_address
check_non_empty RPC_ADDRESS $RPC_ADDRESS
run_cmd "sed -i 's/start_rpc:.*/start_rpc: true/g' $CONF_DIR/cassandra.yaml"
run_cmd "sed -i 's/rpc_address:.*/rpc_address: $RPC_ADDRESS/g' $CONF_DIR/cassandra.yaml"

# Set authenticator
check_non_empty AUTHENTICATOR $AUTHENTICATOR
run_cmd "sed -i 's/authenticator:.*/authenticator: $AUTHENTICATOR/g' $CONF_DIR/cassandra.yaml"

# Set snitch
check_non_empty ENDPOINT_SNITCH $ENDPOINT_SNITCH
run_cmd "sed -i 's/endpoint_snitch:.*/endpoint_snitch: $ENDPOINT_SNITCH/g' $CONF_DIR/cassandra.yaml"

# Set heap size
run_cmd "sed -i 's/#MAX_HEAP_SIZE=.*/MAX_HEAP_SIZE=$MAX_HEAP_SIZE/g' $CONF_DIR/cassandra-env.sh"
run_cmd "sed -i 's/#HEAP_NEWSIZE=.*/HEAP_NEWSIZE=$HEAP_NEWSIZE/g' $CONF_DIR/cassandra-env.sh"

# Override cassandra-rackdc.properties file
run_cmd "cp cassandra-rackdc.properties $CONF_DIR"

echo "Cassandra successfully configured."
