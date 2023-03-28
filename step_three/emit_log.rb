require 'bunny'

# Estabelece a conexão com RabbitMQ
connection = Bunny.new
connection.start

# Criação do canal
channel = connection.create_channel

# Criação de uma exchange do tipo fanout chamada logs
exchange = channel.fanout('logs')

# Mensagem
message = ARGV.empty? ? 'Hello World!' : ARGV.join(' ')

# Dentro do parênteses está a msg a ser enviada usando uma exchange do tipo fanout
exchange.publish(message)
puts " [x] Sent #{message}"

# Fechamento da conexão
connection.close
