#/bin/bash

# You need to install curl and jq

# Gets reading for device 4

curl -s http://api-staging.smartcitizen.me/v0/devices/4 | jq '.data.sensors[2].value'
