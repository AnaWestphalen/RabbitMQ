require 'bunny'

# Estabelece a conexão com RabbitMQ
connection = Bunny.new
connection.start

# Criação do canal
channel = connection.create_channel

# Criação de uma exchange do tipo fanout chamada logs
exchange = channel.fanout('logs')

# Criação da fila com nome definido randomicamente
# Quando o consumidor for desconectado a fila deverá ser automaticamente deletada
queue = channel.queue('', exclusive: true)

# declaração do binding, que é o relacionamento entre a exchange e a fila
queue.bind(exchange)

puts ' [*] Waiting for logs. To exit press CTRL+C'

begin
  queue.subscribe(block: true) do |_delivery_info, _properties, body|
    puts " [x] #{body}"
  end
rescue Interrupt => _
  channel.close
  connection.close
end
