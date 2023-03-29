require 'bunny'

# Estabelece a conexão com o RabbitMQ
connection = Bunny.new(automatically_recover: false)
connection.start

# Criação do canal
channel = connection.create_channel

# Criação da exchange
exchange = channel.topic('topic_logs')

# Definição da chave do roteador (routing_key)
severity = ARGV.shift || 'anonymous.info'

# Mensagem
message = ARGV.empty? ? 'Hello World!' : ARGV.join(' ')

# Dentro do parênteses está a msg a ser enviada usando uma exchange do tipo topic
# No terminal será possível visializar a routing_key seguida da msg
exchange.publish(message, routing_key: severity)
puts " [x] Sent #{severity}:#{message}"

# Fechamento da conexão
connection.close
