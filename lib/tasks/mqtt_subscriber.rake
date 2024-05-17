require 'benchmark'
namespace :mqtt do
  task sub: :environment do
    pid_file = Rails.root.join('tmp/pids/mqtt_subscriber.pid')
    File.open(pid_file, 'w') { |f| f.puts Process.pid }
    mqtt_log = Logger.new('log/mqtt.log', 5, 100.megabytes)

    mqtt_topics_string = ENV.fetch('MQTT_TOPICS', '')
    mqtt_topics = mqtt_topics_string.include?(",") ? mqtt_topics_string.split(",") : [ mqtt_topics_string ]

    mqtt_log.info('MQTT TASK STARTING')
    mqtt_log.info("clean_session: #{MQTTClientFactory.default_clean_session}")
    mqtt_log.info("client_id: #{MQTTClientFactory.default_client_id}")
    mqtt_log.info("host: #{MQTTClientFactory.default_host}")
    mqtt_log.info("port: #{MQTTClientFactory.default_port}")
    mqtt_log.info("ssl: #{MQTTClientFactory.default_ssl}")

    begin
      MQTTClientFactory.create_client do |client|

        mqtt_log.info "Connected to #{client.host}"
        mqtt_log.info "Using clean_session setting: #{client.clean_session}"

        client.subscribe(*mqtt_topics.flat_map { |topic|
          topic = topic == "" ? topic : topic + "/"
          [
            "$queue/#{topic}device/sck/+/readings" => 2,
            "$queue/#{topic}device/sck/+/readings/raw" => 2,
            "$queue/#{topic}device/sck/+/hello" => 2,
            "$queue/#{topic}device/sck/+/info" => 2,
            "$queue/#{topic}device/inventory" => 2
          ]
        })

        mqtt_log.info "SUBSCRIBED!!"
        client.get do |topic, message|
          mqtt_log.info "MESSAGE! "
          Sentry.with_scope do
            begin
              time = Benchmark.measure do
                cleaned_message = message.force_encoding("ascii").encode("utf-8",
                  invalid: :replace, undef: :replace, replace: "", universal_newline: true
                )
                HandleIncomingMQTTMessageJob.perform_later(topic, cleaned_message)
              end
              mqtt_log.info "Processed MQTT message in #{time}"
              mqtt_log.info "MQTT queue length: #{client.queue_length}"
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
