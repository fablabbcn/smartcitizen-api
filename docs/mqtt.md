# MQTT

Readings ingestion for devices above SCK 1.5 is done using MQTT

## MQTT Broker: [EMQX 5.*](http://emqx.io)

EMQ [Documentation](hhttps://www.emqx.io/docs/en/latest/)

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

If running on Docker, there should be a EMQX Dashboard running on http://localhost:18083 (Log in with **admin:public**)

The following will send a message from the `app` container to the `mqtt` container:

1. Subscribe to a Websocket topic called "test" in the Dashboard http://localhost:18083/#/websocket

2. Access the rails console inside the `app` container:

   `docker-compose exec app bin/rails console`

3. Send a message to the `test` topic:

   `MQTT::Client.connect('mqtt').publish('test', 'this is the message')`

## Production deployment

1. Install certbot, and [docker](https://docs.docker.com/engine/install/ubuntu/).

    ```
    sudo apt install certbot
    ```

    For docker follow the instructions.

2. Create a user and a group in host machine with `emqx` as name and 1000 as uid

    ```
    useradd emqx -u 1000
    ```

3. Prepare certificates target folder:

    ```
    mkdir -p /etc/emqx/certs
    chown -R emqx /etc/emqx
    ```

4. Set IP Tables (only for legacy devices that post on port 80!)

    ```
    iptables -t nat -A PREROUTING -i eth0 -p tcp -m tcp --dport 80 -m comment --comment "Redirect port 80 to 1883" -j REDIRECT --to-ports 1883
    iptables -t nat -A PREROUTING -i eth0 -p tcp -m tcp --dport 443 -m comment --comment "Redirect port 443 to 8883" -j REDIRECT --to-ports 8883
    ```

5. Create `/root/emqx/etc/acl.conf` file

    ```
    mkdir -p /root/emqx/etc
    ```

   `acl.conf`:

    ```
    {allow, {user, "<username>"}, subscribe, ["$SYS/#", "#"]}.
    {allow, {ipaddr, "127.0.0.1"}, all, ["$SYS/#", "#"]}.
    %% ---- this is for workshops
    {allow, {user, "<workshops>"}, subscribe, ["lab/#"]}.
    %% ---- add SC API ip addresses here:
    {allow, {ipaddr, "<staging-api-ip-address>"}, all, ["$SYS/#", "#"]}.
    {allow, {ipaddr, "<api-ip-address>"}, all, ["$SYS/#", "#"]}.
    {allow, {ipaddr, "<api-local-ip-address>"}, all, ["$SYS/#", "#"]}.

    {allow, all, publish, ["#"]}.

    %%{deny, all, subscribe, ["$SYS/#", {eq, "#"}]}.
    {deny, all}.
    ```

6. Turn off swap:

    ```
    sudo swapoff -a
    ```

    Permanent change. Open `/etc/fstab` and comment swap line:

    ```
    $ vi /etc/fstab
    ```

7. Get the certificate (with `certonly`, as emqx has a server that we don't know if it's nginx or other):

    ```
    $ certbot certonly -d DOMAIN.DOMAIN.ME
    ```

    When prompted, select `1: Spin up a temporary webserver (standalone)`

    Certificates results:

    ```shell!
    Successfully received certificate.
    Certificate is saved at: /etc/letsencrypt/live/DOMAIN.DOMAIN.ME/fullchain.pem
    Key is saved at:         /etc/letsencrypt/live/DOMAIN.DOMAIN.ME/privkey.pem
    ```

8. In the particular case of the SC MQTT Broker, we do a redirect of port 80 to 1883 and 443 to 8883 to cover for old devices. This prevents certbot to renew the certificates, so it's better to use `dns-01` certificate challenge. Follow the steps here: https://cloudness.net/certbot-dns-challenge/

    Make sure you make the CNAME step before making the `dns-01` final step:

    ![](https://hackmd.io/_uploads/B123gxzy6.png)

    If we have already gotten the certificates using `http-01` method, then go to:

    ```
    vim /etc/letsencrypt/renewal/DOMAIN.DOMAIN.ME.conf
    ```

    And modify the file to do:

    ```
    # renew_before_expiry = 30 days
    version = 0.40.0
    archive_dir = /etc/letsencrypt/archive/DOMAIN.DOMAIN.ME
    cert = /etc/letsencrypt/live/DOMAIN.DOMAIN.ME/cert.pem
    privkey = /etc/letsencrypt/live/DOMAIN.DOMAIN.ME/privkey.pem
    chain = /etc/letsencrypt/live/DOMAIN.DOMAIN.ME/chain.pem
    fullchain = /etc/letsencrypt/live/DOMAIN.DOMAIN.ME/fullchain.pem

    # Options used in the renewal process
    [renewalparams]
    account = xxxxxxx
    pref_challs = dns-01,
    authenticator = manual
    manual_auth_hook = /etc/letsencrypt/acme-dns-auth.py
    server = https://acme-v02.api.letsencrypt.org/directory
    manual_public_ip_logging_ok = True
    ```

8. Set up post-renewal hook in `/etc/letsencrypt/renewal-hooks/post/emqx.sh`:

    ```
    #!/bin/bash
    set -eou pipefail

    DOMAIN='DOMAIN.DOMAIN.ME'

    echo 'Copying and chown to EMQX...'
    cp -L -r /etc/letsencrypt/live/$DOMAIN/*.pem /etc/emqx/certs/
    chown emqx /etc/emqx/certs/*.pem

    echo 'Done'
    ```

7. Set firewall. Remember to change the `<ssh-port>` with the one you are using:

    ```
    ufw disable
    ufw allow proto tcp from any to any port <ssh-port>

    sudo ufw default deny incoming
    sudo ufw default deny outgoing

    echo "Setting in rules..."
    # HTTP/S
    ufw allow in 80
    ufw allow in 443
    # SSH
    ufw allow in <ssh-port>
    ufw allow in <ssh-port>
    # MQTT/S
    ufw allow in 1883
    ufw allow in 8883
    # WS/S
    ufw allow in 8083
    ufw allow in 8084
    # DASHBOARD
    ufw allow in 18084
    # GRAFANA
    ufw allow in 12345

    echo "Setting out rules..."
    # HTTP/S
    ufw allow out 80
    ufw allow out 443
    # DNS/S
    ufw allow out 53
    ufw allow out 853
    # SSH
    ufw allow out <ssh-port>
    ufw allow out <ssh-port>
    # MQTT/S
    ufw allow out 1883
    ufw allow out 8883
    # WS/S
    ufw allow out 8083
    ufw allow out 8084
    # DASHBOARD
    ufw allow out 18084
    # GRAFANA
    ufw allow out 12345

    echo "Remember to enable via ufw enable"
    ```

8. Setup emqx container docker-compose.yml

    ```
    services:
      emqx:
         image: emqx:latest
         container_name: emqx
         environment:
            - "EMQX_MQTT__UPGRADE_QOS=true"
            - "EMQX_MQTT__MQUEUE_STORE_QOS0=true"
            - "EMQX_MQTT__SESSION_EXPIRY_INTERVAL=960h"
            - "EMQX_MQTT__MAX_MQUEUE_LEN=10000000"
            - "EMQX_NODE__COOKIE=sc_emqx"
            - "EMQX_ALLOW_ANONYMOUS=false"
            - "EMQX_LISTENER__SSL__KEYFILE=/opt/emqx/etc/certs/privkey.pem"
            - "EMQX_LISTENER__SSL__CERTFILE=/opt/emqx/etc/certs/fullchain.pem"
            - "EMQX_LISTENER__WSS__KEYFILE=/opt/emqx/etc/certs/privkey.pem"
            - "EMQX_LISTENER__WSS__CERTFILE=/opt/emqx/etc/certs/fullchain.pem"
            - "EMQX_DASHBOARD__LISTENERS__HTTP__ENABLE=true"
            - "EMQX_DASHBOARD__LISTENERS__HTTP__BIND=18083"
            - "EMQX_DASHBOARD__LISTENERS__HTTP__MAX_CONNECTIONS=5"
            - "EMQX_DASHBOARD__LISTENERS__HTTPS__ENABLE=true"
            - "EMQX_DASHBOARD__LISTENERS__HTTPS__BIND=18084"
            - "EMQX_DASHBOARD__LISTENERS__HTTPS__MAX_CONNECTIONS=5"
            - "EMQX_DASHBOARD__LISTENERS__HTTPS__KEYFILE=/opt/emqx/etc/certs/privkey.pem"
            - "EMQX_DASHBOARD__LISTENERS__HTTPS__CERTFILE=/opt/emqx/etc/certs/fullchain.pem"
         restart: unless-stopped
         deploy:
            resources:
            limits:
               memory: 3g
         healthcheck:
            test: ["CMD", "/opt/emqx/bin/emqx", "ctl", "status"]
            interval: 5s
            timeout: 25s
            retries: 5
         ports:
            - 1883:1883
            - 8083:8083
            - 8084:8084
            - 8883:8883
            - 18083:18083
            - 18084:18084
         volumes:
            - "/etc/emqx/certs:/opt/emqx/etc/certs:ro"
            - "/root/emqx/etc/acl.conf:/opt/emqx/etc/acl.conf"
            - "/root/emqx/log:/opt/emqx/log"
    ```

9. Run

```
docker compose up -d
```

Issues for discussion:

https://github.com/emqx/emqx/discussions/12094#discussioncomment-8002548

