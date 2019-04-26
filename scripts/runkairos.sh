#!/bin/bash

export CASS_AUTH_PASS=${CASS_AUTH_PASS:-"cass_password"}
export CASS_AUTH_USER=${CASS_AUTH_USER:-"cass_user"}
export CASS_HOSTS=${CASS_HOSTS:-"cassandra-1"}
export KAIROS_JETTY_PORT=${KAIROS_JETTY_PORT:-8080}
export KAIROS_TELNET_ADDRESS=${KAIROS_TELNET_ADDRESS:-0.0.0.0}
export kairos_telnet_port=${kairos_telnet_port:-4242}
export K_PASS=${K_PASS:-"kairos_password"}
export K_USER=${K_USER:-"admin"}
export PORT_CARBON_PICKLE=${PORT_CARBON_PICKLE:-2004}
export PORT_CARBON_TEXT=${PORT_CARBON_TEXT:-2003}
export READ_CONSISTENCY_DATA=${READ_CONSISTENCY_DATA:-ONE}
export READ_CONSISTENCY_INDEX=${READ_CONSISTENCY_INDEX:-ONE}
export READ_CONSISTENCY_INDEX=${WRITE_CONSISTENCY_INDEX:-QUORUM}
export REPFACTOR=${REPFACTOR:-1}
export WRITE_CONSISTENCY_DATA=${WRITE_CONSISTENCY_DATA:-QUORUM}

function main {
  echo "---- kairosdb.properties ----"
  envsubst < /tmp/kairosdb.properties > /opt/kairosdb/conf/kairosdb.properties
  cat /opt/kairosdb/conf/kairosdb.properties
  echo "---- end kairosdb.properties ----"
  /opt/kairosdb/bin/kairosdb.sh run
}

main "$@"
