#!/usr/bin/env node
const fetch = require('node-fetch');

function postReadings(url, deviceId, sensorId, token, length, sensorValue = 10) {

  if (url == null) {
    console.log("Usage:\nnode post-readings.js url deviceId, sensorId, token, nrOfLines\n")
    console.log("Example:\nnode post-readings.js 'http://localhost:3000/v0' 4 12 'd0e50e139b35d646719ce2046e79b8ded8e5c48cd73ff7c9ea9ca6757a837082' 10000\n")
    console.log("Get the Token by posting example:\ncurl -XPOST 'http://localhost:3000/v0/sessions?username=user1&password=password' -d '' \n")
    return;
  }

  const body = { data:[] };

  for(let j = 0; j < length; j++) {
    body.data.push({"recorded_at":new Date(+(new Date()) - Math.floor(Math.random()*100000000)),"sensors":[{"id": sensorId, "value":parseFloat(sensorValue) + Math.random() }]});
  }
  var myInit = {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify(body)
  };
  fetch(`${url}/devices/${deviceId}/readings`,myInit)
    .then(res => res.json())
    .then(res => console.log(res));

  /*
  console.log('url: ' + url);
  console.log('deviceId: ' + deviceId);
  console.log('sensorId: ' + sensorId);
  console.log('Token: ' + token);
  console.log('length: ' + length);
  */

  console.log( body.data[body.data.length -1]['sensors'][0]['value']  );
}

postReadings(...process.argv.slice(2));
