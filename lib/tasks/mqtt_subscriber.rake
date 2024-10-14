require 'benchmark'
namespace :mqtt do
  task sub: :environment do
    pid_file = Rails.root.join('tmp/pids/mqtt_subscriber.pid')
    File.open(pid_file, 'w') { |f| f.puts Process.pid }

    mqtt_clean_session = ENV.has_key?('MQTT_CLEAN_SESSION') ? ENV['MQTT_CLEAN_SESSION'] == "true" : true
    mqtt_client_id = ENV.has_key?('MQTT_CLIENT_ID') ? ENV['MQTT_CLIENT_ID'] : nil
    mqtt_host = ENV.has_key?('MQTT_HOST') ? ENV['MQTT_HOST'] : 'mqtt'
    mqtt_port = ENV.has_key?('MQTT_PORT') ? ENV['MQTT_PORT'] : 1883
    mqtt_ssl = ENV.has_key?('MQTT_SSL') ? ENV['MQTT_SSL'] : false
    mqtt_shared_subscription_group = ENV.fetch("MQTT_SHARED_SUBSCRIPTION_GROUP", nil)
    mqtt_queue_length_warning_threshold = ENV.fetch("MQTT_QUEUE_LENGTH_WARNING_THRESHOLD", "30").to_i

    mqtt_topics_string = ENV.fetch('MQTT_TOPICS', '')
    mqtt_topics = mqtt_topics_string.include?(",") ? mqtt_topics_string.split(",") : [ mqtt_topics_string ]

    if mqtt_shared_subscription_group && mqtt_clean_session
      mqtt_client_id += "-#{ENV.fetch("HOSTNAME")}"
    end

    mqtt_log = Logger.new("log/mqtt-#{mqtt_client_id}.log", 5, 100.megabytes)
    mqtt_log.info('MQTT TASK STARTING')
    mqtt_log.info("clean_session: #{mqtt_clean_session}")
    mqtt_log.info("client_id: #{mqtt_client_id}")
    mqtt_log.info("host: #{mqtt_host}")
    mqtt_log.info("port: #{mqtt_port}")
    mqtt_log.info("ssl: #{mqtt_ssl}")

    begin
      MQTTClientFactory.create_client(
        :host => mqtt_host,
        :port => mqtt_port,
        :clean_session => mqtt_clean_session,
        :client_id => mqtt_client_id,
        :ssl => mqtt_ssl
      ) do |client|

        mqtt_log.info "Connected to #{client.host}"
        mqtt_log.info "Using clean_session setting: #{client.clean_session}"

        message_handler = MqttMessagesHandler.new
        prefix = mqtt_shared_subscription_group ? "$share/#{mqtt_shared_subscription_group}" : "$queue"
        client.subscribe(*mqtt_topics.flat_map { |topic|
          topic = topic == "" ? topic : topic + "/"
          [
            "#{prefix}/#{topic}device/sck/+/readings" => 2,
            "#{prefix}/#{topic}device/sck/+/readings/raw" => 2,
            "#{prefix}/#{topic}device/sck/+/hello" => 2,
            "#{prefix}/#{topic}device/sck/+/info" => 2,
            "#{prefix}/#{topic}device/inventory" => 2
          ]
        })
        threshold_passed = false
        client.get do |topic, message|
          Sentry.with_scope do
            begin
              time = Benchmark.measure do
                message_handler.handle_topic(topic, message)
              end
              mqtt_log.info "Processed MQTT message in #{time}"
              mqtt_log.info "MQTT queue length: #{client.queue_length}"
              if client.queue_length >= mqtt_queue_length_warning_threshold
                if !threshold_passed
                  Sentry.capture_message("Warning: Internal MQTT queue length is #{client.queue_length} (>= #{mqtt_queue_length_warning_threshold} on client #{mqtt_client_id}).")
                  threshold_passed = true
                end
              else
                threshold_passed = false
              end
            rescue Exception => e
              mqtt_log.info e
              Sentry.capture_exception(e)
            end
          end
        end
      end
    rescue SystemExit, Interrupt, SignalException
      File.delete pid_file
      exit 0
    rescue Exception => e
      begin
        Sentry.capture_exception(e)
        mqtt_log.info e
        mqtt_log.info "Try to reconnect in 10 seconds..."
        sleep 10
        retry
      rescue SystemExit, Interrupt, SignalException
        File.delete pid_file
        exit 0
      end
    end
  end
end
