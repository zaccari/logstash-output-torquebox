# encoding: utf-8
require 'logstash/outputs/base'
require 'logstash/namespace'

class LogStash::Outputs::Torquebox < LogStash::Outputs::Base

  config_name 'torquebox'

  # Address of the TorqueBox HornetQ host to connect to
  config :host, validate: :string, default: '0.0.0.0'

  # Port on the TorqueBox HornetQ host to connect to
  config :port, validate: :number, default: 5445

  # TorqueBox topologies:
  #   topic - Publish / Subscribe
  #   queue - Producer / Consumer
  #
  # For more information, see:
  #   http://torquebox.org/documentation/3.1.2/messaging.html
  config :topology, validate: ['topic', 'queue'], required: true

  # The name of the topic or queue to use
  config :name, validate: :string, required: true

  # Specifies the serialization encoding to use for the message. TorqueBox
  # provides the following built-in encodings:
  #
  #   :marshal        - The message is encoded/decoded via Marshal, and is
  #                     transmitted as a binary message.
  #   :marshal_base64 - The message is encoded/decoded via Marshal, and is
  #                     transmitted as a base64 encoded text message. This was
  #                     the encoding scheme used in TorqueBox 1.x.
  #   :json           - The message is encoded/decoded via JSON, and is
  #                     transmitted as a text message. This encoding is limited,
  #                     and should only be used for simple messages.
  #   :edn            - The message is encoded/decoded via the edn gem, and is
  #                     transmitted as a text message. This encoding is most
  #                     convenient for messages that can be represented using
  #                     standard Clojure data structures.
  #   :text           - The message isn't encoded/decoded at all, and is passed
  #                     straight through as a text message. The content of the
  #                     message must be a string.
  config :encoding, validate: ['marshal', 'marshal_base64', 'json', 'edn', 'text'], default: 'marshal'

  # The maximum time to wait for the destination to become ready on initial app
  # startup, in milliseconds. On a very slow machine this may need to be increased
  # from the default.
  config :startup_timeout, validate: :number, default: 500

  def register
    require 'torquebox-messaging'

    @publish_opts = { encoding: @encoding, startup_timeout: @startup_timeout }

    @logger.info "TorqueBox #{@topology}:#{@name}@#{@host}:#{@port} - #{@publish_opts}"

    if @topology == 'topic'
      @destination = TorqueBox::Messaging::Topic.new(@name, host: @host, port: @port)
    else
      @destination = TorqueBox::Messaging::Queue.new(@name, host: @host, port: @port)
    end
  end

  def receive(event)
     @logger.debug('Sending message to destination', event: event)

    begin
      @destination.publish(event.to_json, @publish_opts)
    rescue javax.jms.JMSException => e
      @logger.error("Torquebox destination is not available", exception: e)
    rescue => e
      @logger.error("Failed to send event #{event}", exception: e)
    end
  end

end
