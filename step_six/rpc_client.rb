require 'bunny'
require 'thread'

class FibonacciClient
  attr_accessor :call_id, :response, :lock, :condition, :connection,
                :channel, :server_queue_name, :reply_queue, :exchange

  def initialize(server_queue_name)
    @connection = Bunny.new(automatically_recover: false)
    @connection.start

    @channel = @connection.create_channel
    @exchange = @channel.default_exchange
    @server_queue_name = server_queue_name

    setup_reply_queue
  end

  def call(n)
    @call_id = generate_uuid

    exchange.publish(n.to_s,
                     routing_key: server_queue_name,
                     correlation_id: call_id,
                     reply_to: reply_queue.name)

    # Aguarda o sinal para continuar a execução
    lock.synchronize { condition.wait(lock) }

    response
  end

  def stop
    channel.close
    connection.close
  end

  private

  def setup_reply_queue
    @lock = Mutex.new
    @condition = ConditionVariable.new
    that = self
    @reply_queue = channel.queue('', exclusive: true)

    reply_queue.subscribe do |_delivery_info, properties, payload|
      if properties[:correlation_id] == that.call_id
        that.response = payload.to_i

        # envia o sinal para continuar a execução do método #call
        that.lock.synchronize { that.condition.signal }
      end
    end
  end

  def generate_uuid
    "#{rand}#{rand}#{rand}"
  end
end

client = FibonacciClient.new('rpc_queue')

puts " [x] Requesting fib(30)"
response = client.call(30)

puts " [.] Got #{response}"

client.stop
