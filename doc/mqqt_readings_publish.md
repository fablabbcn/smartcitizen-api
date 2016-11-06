# SCK 1.5 Ingestion

## MQTT Broker: EMQ 2.0 http://emqtt.io

EMQ Documentation: http://emqttd-docs.readthedocs.io/en/latest/index.html

## Readings Subscriptions

The new system makes use of EMQ Shared Subscription system with Load balancing. Ensuring message distribution among currently active subscribers of a 'shared' topic, therefore avoiding duplicated readings.

MQTT host address is held in ```config/aplication.yml``` under ```ENV["mqtt_host"]``` variable. Although it must be provided for ```'production'```, ```127.0.0.1``` is set by default on ```'test'``` and ```'development'``` environments if not specified.
Note: It is required defining ```ENV["mqtt_host"]``` for ```production``` as an exception will be thrown at server startup otherwise.

## Readings Publish

Devices publish using the topic ```/device/sck/device_id:/readings``` and the expected payload is of the following form:
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
It is important messages are published using QoS of 0, as in case of connection issues using 1 or 2, could result in duplicated readings being processed.
