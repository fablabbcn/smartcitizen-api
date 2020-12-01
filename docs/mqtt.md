# MQTT

Readings ingestion for devices above SCK 1.5 is done using MQTT

## MQTT Broker: [EMQ 2.0](http://emqtt.io)

EMQ [Documentation](http://emqttd-docs.readthedocs.io/en/latest/index.html)

## Readings Subscriptions

The new system makes use of EMQ Shared Subscription system with Load balancing. This ensures messages distribution among currently active subscribers of a 'shared' topic.

MQTT host address is held in `.env` under the `ENV["MQTT_HOST"]` variable. Although it must be provided for `'production'`, `127.0.0.1` is set by default on `'test'` and `'development'` environments if not specified.

> NOTE: It is required defining `ENV["MQTT_HOST"]` and `ENV["MQTT_CLIENT"]` for `production` as an exception will be thrown at server startup otherwise. 

## End-points

As on [mqtt_messages_handler.rb](https://github.com/fablabbcn/smartcitizen-api/blob/master/app/lib/mqtt_messages_handler.rb)

* `device/sck/%s/info` used by a device to publish hardware related info periodically, mostly daily
* `device/sck/%s/hello` used by a device to notify it is alive under an specific device-token
* `device/sck/%s/readings` used by a device to publish one or multiple sensor readings
* `device/sck/%s/readings/raw` used by a device to publish sensor readings in "raw" form
* `device/inventory` used by a device to publish information during the factory test procedure


## Readings Publish

Devices publish using the topic `device/sck/device_token:/readings` and the expected payload is of the following form:

```
{
  "data": [{
    "recorded_at": "2016-06-08 10:30:00",
    "sensors": [{ "id": 1, "value": 21 }]
  },{
    "recorded_at": "2016-06-08 10:35:00",
    "sensors": [{ "id": 1, "value": 22 }]
  }]
}
```

Devices can also publish to the topic `device/sck/device_token:/readings/raw` with a different (shorter) payload format:

```
{
  t:2017-03-24T13:35:14Z,
  1:21,
  13:66,
}
```

* Each device is identified by a unique `device_token`.

* Every device has sensor(s). A `sensor` is something on a device that can record data. This could be anything, some examples are - temperature, humidity, battery percentage, # wifi networks. A list of all the available sensors can be retrieve via the [API](http://developer.smartcitizen.me/#sensors).

* Messages must be published using QoS (Quality of Service) of 1.

## Development and test 

### Working with MQTT locally (no Docker)

1. Start an mqtt server like mosquitto

2. Subscribe to a topic (useful for debugging):

   `mosquitto_sub --topic '$queue/device/sck/abcdef/hello'`

3. Start the mqtt rake task:

   `bundle exec rake mqtt:sub MQTT_HOST=localhost`

4. Publish a packet

   `mosquitto_pub --message abcdef  --topic '$queue/device/sck/abcdef/hello'`

### Working with MQTT and WebSockets via Docker

If running on Docker, there should be a EMQ Dashboard running on http://localhost:18083 (Log in with **admin:public**)

The following will send a message from the `app` container to the `mqtt` container:

1. Subscribe to a Websocket topic called "test" in the Dashboard http://localhost:18083/#/websocket

2. Access the rails console inside the `app` container:

   `docker-compose exec app bin/rails console`

3. Send a message to the `test` topic:

   `MQTT::Client.connect('mqtt').publish('test', 'this is the message')`
