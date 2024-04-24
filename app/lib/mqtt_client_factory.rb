module MQTTClientFactory
  def self.create_client(args={}, &block)
    host          = args.fetch(:host, default_host)
    port          = args.fetch(:port, default_port)
    clean_sesion  = args.fetch(:clean_session, default_clean_session)
    client_id     = args.fetch(:client_id, default_client_id)
    ssl           = args.fetch(:ssl, default_ssl)
    MQTT::Client.connect(
      { host: host, port: port, clean_session: clean_sesion, client_id: client_id, ssl: ssl},
      &block
    )
  end

  def self.default_host
    ENV.fetch('MQTT_HOST', 'mqtt')
  end

  def self.default_port
    ENV.fetch('MQTT_PORT', "1883").to_i
  end

  def self.default_clean_session
    ENV.fetch('MQTT_CLEAN_SESSION', "true") == "true"
  end

  def self.default_client_id
    ENV.fetch('MQTT_CLIENT_ID', nil)
  end

  def self.default_ssl
    ENV.fetch('MQTT_SSL', "false") == "true"
  end
end
