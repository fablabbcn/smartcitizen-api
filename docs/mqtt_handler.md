https://github.com/fablabbcn/smartcitizen-api/blob/master/app/lib/mqtt_messages_handler.rb

* `device/sck/%s/info` used by a device to publish hardware related info periodically, mostly daily
* `device/sck/%s/hello` used by a device to notify it is alive under an specific device-token
* `device/sck/%s/readings` used by a device to publish one or multiple sensor readings
* `device/inventory` used by a device to publish information during the factory test procedure
