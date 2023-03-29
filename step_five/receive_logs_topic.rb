require 'bunny'

# Estabelece a conexão com o RabbitMQ
connection = Bunny.new
connection.start

# Criação do canal
channel = connection.create_channel

# Criação da exchange
exchange = channel.topic('topic_logs')

# Criação da fila com nome definido randomicamente
# Quando o consumidor for desconectado a fila deverá ser automaticamente deletada
queue = channel.queue('', exclusive: true)

# declaração do binding, que é o relacionamento entre a exchange e a fila
# A fila está interessada nas mensagens dessa exchange
# Criação de um novo binding para cada severity que nos interessa
ARGV.each do |severity|
  queue.bind(exchange, routing_key: severity)
end

puts ' [*] Waiting for logs. To exit press CTRL+C'

begin
  queue.subscribe(block: true) do |delivery_info, _properties, body|
    puts " [x] #{delivery_info.routing_key}:#{body}"
  end
rescue Interrupt => _
  channel.close
  connection.close

  exit(0)
end
