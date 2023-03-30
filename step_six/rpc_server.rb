require 'bunny'

class FibonacciServer
  # Inicialização padrão estabelecendo a conexação, o canal e declarando a fila
  def initialize
    @connection = Bunny.new
    @connection.start
    @channel = @connection.create_channel
  end

  def start(queue_name)
    @queue = channel.queue(queue_name)
    @exchange = channel.default_exchange
    subscribe_to_queue
  end

  def stop
    channel.close
    connection.close
  end

  def loop_forever
    # Este loop só existe para manter a thread principal vivo.
    # Muitos aplicativos do mundo real não precisam disso.
    loop { sleep 5 }
  end

  private

  attr_reader :channel, :exchange, :queue, :connection

  # Método para consumir mensagens da fila
  def subscribe_to_queue
    queue.subscribe do |_delivery_info, properties, payload|
      result = fibonacci(payload.to_i)

      exchange.publish(
        result.to_s,
        routing_key: properties.reply_to,
        correlation_id: properties.correlation_id
      )
    end
  end

  def fibonacci(value)
    return value if value.zero? || value == 1

    fibonacci(value - 1) + fibonacci(value - 2)
  end
end

begin
  server = FibonacciServer.new

  puts ' [x] Awaiting RPC requests'
  server.start('rpc_queue')
  server.loop_forever
rescue Interrupt => _
  server.stop
end
