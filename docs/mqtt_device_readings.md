# SCK 1.5 Ingestion

## MQTT Broker: [EMQ 2.0](http://emqtt.io)

EMQ [Documentation](http://emqttd-docs.readthedocs.io/en/latest/index.html)

### Readings Subscriptions

The new system makes use of EMQ Shared Subscription system with Load balancing. This ensures messages distribution among currently active subscribers of a 'shared' topic.

MQTT host address is held in `.env` under the `ENV["mqtt_host"]` variable. Although it must be provided for `'production'`, `127.0.0.1` is set by default on `'test'` and `'development'` environments if not specified.

> NOTE: It is required defining `ENV["mqtt_host"]` for `production` as an exception will be thrown at server startup otherwise.

### Readings Publish

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

* Each device is identified by a unique `device_token`.

* Every device has sensor(s). A `sensor` is something on a device that can record data. This could be anything, some examples are - temperature, humidity, battery percentage, # wifi networks. A list of all the available sensors can be retrieve via the [API](http://developer.smartcitizen.me/#sensors).

* Messages must be published using QoS (Quality of Service) of 1.