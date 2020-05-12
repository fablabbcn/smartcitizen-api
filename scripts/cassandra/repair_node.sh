#!/bin/sh
#
# based on https://stackoverflow.com/a/7755563
#
## Usage: repair_node.sh USERNAME PASSWORD NODE_PRIVATE_IP
##
## Repairs all ranges of this node 
##
## Options:
##   -h, --help    Display this message.
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
    (-h|--help) usage 2>&1;;
    (--) shift; break;;
    (-*) usage "$1: unknown option";;
    (*) break;;
    esac
    shift
  done
  if [ $# != 3 ]; then
    echo "Wrong number of arguments: $#"
    usage
  fi
  USERNAME=$1
  PASSWORD=$2
  IP=$3
}

parse_args $*

SIZE_ESTIMATES_CSV="size_estimates.csv"
REPAIR_SCRIPT="repair.sh"

# Get nodes primary ranges via system.size_estimates table
cqlsh -u $USERNAME -p $PASSWORD -e "COPY system.size_estimates to '$SIZE_ESTIMATES_CSV'" $IP
cat $SIZE_ESTIMATES_CSV | awk -F',' '{ print "nodetool repair -st "$3" -et "$4 }' | sort | uniq > $REPAIR_SCRIPT
rm $SIZE_ESTIMATES_CSV

echo "Will start repair"
bash -x $REPAIR_SCRIPT

echo "Completed repair of `wc -l $REPAIR_SCRIPT` ranges successfully."
rm $REPAIR_SCRIPT
