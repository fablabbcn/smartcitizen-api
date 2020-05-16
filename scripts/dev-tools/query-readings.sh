#/bin/bash

# You need to install curl and jq

# Gets reading for device 4

if [ "$1" = "localhost" ]; then
  echo "Querying localhost"
  curl -s http://localhost:3000/v0/devices/4 | jq '.data.sensors[2].value'
else
  echo "Querying staging"
  curl -s http://staging-api.smartcitizen.me/v0/devices/4 | jq '.data.sensors[2].value'
fi
