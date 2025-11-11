#!/usr/bin/env python3

# Simple script to republish smartcitizen data from a private MQTT server
# to the public MQTT server at smartcitizen.me.
# If you changed the MQTT server in you SmartCitizen Kit to your own
# server start this script and provide the name/IP of your server by
# the --host parameter.
# e.g. republish_smartcitizen.py --host mqtt.mydomain.org

import argparse
import paho.mqtt.client as mqtt
import paho.mqtt.publish as publish

topic = 'device/sck/#'
write_srv = 'mqtt.smartcitizen.me'

def on_read_connect(client, userdata, flags, rc):
	self = userdata
	if self.args.verbose:
		print ("Connected with result: "+str(rc))
	self.mqtt_client.subscribe(topic, 1)

def on_read_disconnect(client, userdata, rc):
	self = userdata
	if self.args.verbose:
		print ("Disconnected, trying to reconnect: "+str(rc))
	self.mqtt_client.reconnect()

def on_message(client, userdata, msg):
	self = userdata
	if self.args.verbose:
		print ("Got message: "+msg.topic+": "+str(msg.payload))
	publish.single(msg.topic, msg.payload, hostname=write_srv)

class republish_smartcitizen(object):

	def __init__(self):
		self.mqtt_client = None

	def run(self, args):
		if not self.mqtt_client:
			self.mqtt_client = mqtt.Client()
			self.mqtt_client.user_data_set(self)
			self.mqtt_client.on_connect = on_read_connect
			self.mqtt_client.on_disconnect = on_read_disconnect
			self.mqtt_client.on_message = on_message
			if args.verbose:
				print ("Connecting to "+args.host+":"+str(args.port))
			self.mqtt_client.connect(args.host, args.port, 60)

		self.args = args
		while True:
			self.mqtt_client.loop()

tool = republish_smartcitizen()

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="republish smartcitizen sensor data")
	parser.add_argument('-v', '--verbose', action="store_true")
	parser.add_argument('-H', '--host')
	parser.add_argument('-p', '--port', default=1883)
	args = parser.parse_args()

	tool.run(args)
