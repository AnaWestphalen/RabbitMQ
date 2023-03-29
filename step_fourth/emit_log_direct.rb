require 'bunny'

# Estabelece a conexão com o RabbitMQ
connection = Bunny.new(automatically_recover: false)
connection.start

# Criação do canal
channel = connection.create_channel

# Criação da exchange
exchange = channel.direct('direct_logs')

# Definição da chave do roteador
# Severity, nesse caso, pode ser info, warning ou error.
severity = ARGV.shift || 'info'

# Mensagem
message = ARGV.empty? ? 'Hello World!' : ARGV.join(' ')

# Dentro do parênteses está a msg a ser enviada usando uma exchange do tipo fanout
exchange.publish(message, routing_key: severity)
puts " [x] Sent #{message}"

# Fechamento da conexão
connection.close
