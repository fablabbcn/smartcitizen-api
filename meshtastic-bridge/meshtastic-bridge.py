import base64
import datetime
import os
from string import Template

import paho.mqtt.client as mqtt
import requests
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from meshtastic.protobuf import mqtt_pb2, mesh_pb2
from meshtastic import protocols
from google.protobuf.json_format import MessageToDict

INBOUND_BROKER = os.getenv("MESHTASTIC_INBOUND_MQTT_BROKER", "mqtt.smartcitizen.me")
INBOUND_USER = os.getenv("MESHTASTIC_INBOUND_MQTT_USER")
INBOUND_PASS = os.getenv("MESHTASTIC_INBOUND_MQTT_PASS", "")
INBOUND_PORT = int(os.getenv("MESHTASTIC_INBOUND_MQTT_PORT", 1883))
INBOUND_TOPICS = os.getenv("MESHTASTIC_INBOUND_MQTT_TOPICS", "device/sck/mesh12/2/#").split(",")
INBOUND_KEY = os.getenv("MESHTASTIC_INBOUND_MQTT_KEY", "")

INGEST_TOKEN = os.getenv("MESHTASTIC_INGEST_TOKEN")
API_BASE_URL = os.getenv("MESHTASTIC_SC_API_BASE_URL")

OUTBOUND_BROKER = os.getenv("MESHTASTIC_OUTBOUND_MQTT_BROKER", "mqtt.smartcitizen.me")
OUTBOUND_USER = os.getenv("MESHTASTIC_OUTBOUND_MQTT_USER", "")
OUTBOUND_PASS = os.getenv("MESHTASTIC_OUTBOUND_MQTT_PASS", "")
OUTBOUND_PORT = int(os.getenv("MESHTASTIC_OUTBOUND_MQTT_PORT", 1883))
OUTBOUND_TOPIC = os.getenv("MESHTASTIC_OUTBOUND_MQTT_TOPIC", "device/sck/+/readings/raw")


device_tokens_cache = {}

def get_device_token(meshtastic_id):
    if meshtastic_id in device_tokens_cache:
        return device_tokens_cache[meshtastic_id]
    response = requests.get(f"{API_BASE_URL}/meshtastic/device_token?ingest_token={INGEST_TOKEN}&meshtastic_id={meshtastic_id}")
    if response.status_code == 200:
        token = response.json()["token"]
        if token:
            device_tokens_cache[meshtastic_id] = token
        return token

sensor_ids_cache = {}

def get_sensor_id(device_meshtastic_id, measurement_meshtastic_id):
    if (device_meshtastic_id, measurement_meshtastic_id) in sensor_ids_cache:
        return sensor_ids_cache[(device_meshtastic_id, measurement_meshtastic_id)]
    response = requests.get(f"{API_BASE_URL}/meshtastic/sensor_id?ingest_token={INGEST_TOKEN}&device_meshtastic_id={device_meshtastic_id}&measurement_meshtastic_id={measurement_meshtastic_id}")
    if response.status_code == 200:
        id = response.json()["id"]
        if id:
            sensor_ids_cache[(device_meshtastic_id, measurement_meshtastic_id)] = id
        return id

def on_connect(client, _userdata, _flags, rc):
    if rc == 0:
        print("Connected to MQTT broker!")
        for topic in INBOUND_TOPICS:
            client.subscribe(topic)
            print(f"Subscribed to topic: {topic}")
    else:
        print(f"Failed to connect, return code {rc}")

outbound_client = mqtt.Client()
outbound_client.username_pw_set(OUTBOUND_USER, OUTBOUND_PASS)
outbound_client.connect(OUTBOUND_BROKER, OUTBOUND_PORT, keepalive=60)

def forward_readings(device_meshtastic_id, readings):
    print("IN<--", device_meshtastic_id, readings)
    device_token = get_device_token(device_meshtastic_id)
    packet = transform_meshtastic_data(device_meshtastic_id, readings)
    if device_token and packet:
        topic = OUTBOUND_TOPIC.replace("+", device_token)
        outbound_client.publish(topic, packet)
        outbound_client.loop(timeout=1.0)
        print("OUT-->", topic, packet)
    else:
        print("NO OUT|||")
    print("-----")

def on_message(_client, _userdata, msg):
    se = mqtt_pb2.ServiceEnvelope()
    se.ParseFromString(msg.payload)
    decoded_mp = se.packet

    # Try to decrypt the payload if it is encrypted
    if decoded_mp.HasField("encrypted") and not decoded_mp.HasField("decoded"):
        decoded_data = decrypt_packet(decoded_mp, INBOUND_KEY)
        if decoded_data is not None:
            decoded_mp.decoded.CopyFrom(decoded_data)

    # Attempt to process the decrypted or encrypted payload
    portNumInt = decoded_mp.decoded.portnum if decoded_mp.HasField("decoded") else None
    handler = protocols.get(portNumInt) if portNumInt else None

    pb = None
    if handler is not None and handler.protobufFactory is not None:
        pb = handler.protobufFactory()
        pb.ParseFromString(decoded_mp.decoded.payload)

    if pb:
        pb_dict = MessageToDict(pb, preserving_proto_field_name=True)
        decoded_mp.decoded.payload = str(pb_dict).encode("utf-8")

        # Gather extra info if available
        device_id = getattr(decoded_mp, "from", None)
        packet_id = getattr(decoded_mp, "id", None)
        timestamp = pb_dict.get("time") or pb_dict.get("timestamp")
        iso_time = None
        if timestamp:
            try:
                iso_time = datetime.datetime.utcfromtimestamp(int(timestamp)).strftime("%Y-%m-%dT%H:%M:%SZ")
            except Exception:
                pass
        if portNumInt == 67: # (Telemetry app)
            forward_readings(device_id, pb_dict)


def decrypt_packet(mp, key):
    try:
        key_bytes = base64.b64decode(key.encode('ascii'))

        # Build the nonce from message ID and sender
        nonce_packet_id = getattr(mp, "id").to_bytes(8, "little")
        nonce_from_node = getattr(mp, "from").to_bytes(8, "little")
        nonce = nonce_packet_id + nonce_from_node

        # Decrypt the encrypted payload
        cipher = Cipher(algorithms.AES(key_bytes), modes.CTR(nonce), backend=default_backend())
        decryptor = cipher.decryptor()
        decrypted_bytes = decryptor.update(getattr(mp, "encrypted")) + decryptor.finalize()

        # Parse the decrypted bytes into a Data object
        data = mesh_pb2.Data()
        data.ParseFromString(decrypted_bytes)
        return data

    except Exception:
        return None

def transform_meshtastic_data(device_meshtastic_id, pb_dict):
    readings = {}
    for top_key, sub_dict in pb_dict.items():
        if isinstance(sub_dict, dict):
            for sensor_name, value in sub_dict.items():
                map_key = f"{top_key}.{sensor_name}"
                sensor_id = get_sensor_id(device_meshtastic_id, map_key)
                if sensor_id:
                    readings[sensor_id] = value

    recorded_at = None
    if "time" in pb_dict:
        recorded_at = datetime.datetime.utcfromtimestamp(pb_dict["time"]).strftime("%Y-%m-%dT%H:%M:%SZ")

    if len(readings) > 0:
        sensor_pairs = ",".join([f"{k}:{v}" for (k, v) in readings.items()])
        template = Template("{t:$recorded_at,$sensor_pairs}")
        data = template.substitute({"recorded_at": recorded_at, "sensor_pairs": sensor_pairs})
        return data

inbound_client = mqtt.Client()
inbound_client.on_connect = on_connect
inbound_client.on_message = on_message
inbound_client.username_pw_set(INBOUND_USER, INBOUND_PASS)
try:
    inbound_client.connect(INBOUND_BROKER, INBOUND_PORT, keepalive=60)
    inbound_client.loop_forever()
except Exception as e:
    print(f"An error occurred: {e}")
