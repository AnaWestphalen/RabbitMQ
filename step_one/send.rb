# Biblioteca
require 'bunny'

# Estabelece conexão com o RabbitMQ Server
connection = Bunny.new
connection.start

# Criação do canal
channel = connection.create_channel

# Declaração da fila que será usada para envio da msg
queue = channel.queue('hello')

# Uso do exchange default. Dentro do parênteses está a msg a ser enviada.
channel.default_exchange.publish('Hello World!', routing_key: queue.name)
puts " [x] Sent 'Hello World!'"

# Fechamento da conexão
connection.close
