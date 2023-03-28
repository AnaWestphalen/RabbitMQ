require 'bunny'

# Estabelece conexão com o RabbitMQ Server
connection = Bunny.new(automatically_recover: false)
connection.start

# Criação do canal
channel = connection.create_channel

# Declaração da fila que será usada para envio da msg
# Essa fila sobreviverá a reiniciaçização do RabbitMQ
queue = channel.queue('task_queue', durable: true)

# Mensagem
message = ARGV.empty? ? 'Hello World!' : ARGV.join(' ')

# Dentro do parênteses está a msg a ser enviada.
# Mensagens serão persistentes
queue.publish(message, persistent: true)
puts " [x] Sent #{message}"

# Fechamento da conexão
connection.close
