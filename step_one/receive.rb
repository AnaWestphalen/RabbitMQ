# Biblioteca
require 'bunny'

# Estabelece conexão com o RabbitMQ Server
connection = Bunny.new
connection.start

# Criação do canal
channel = connection.create_channel

# Declaração da fila de onde virá a msg
queue = channel.queue('hello')

# retorno de chamada que será executado quando o RabbitMQ enviar msgs ao nosso consumidor
begin
  puts ' [*] Waiting for messages. To exit press CTRL+C'
  # block: true é usado apenas para manter o thread principal ativo.
  # Evite usá-lo em aplicativos reais.
  queue.subscribe(block: true) do |_delivery_info, _properties, body|
    puts " [x] Received #{body}"
  end
rescue Interrupt => _
  connection.close

  exit(0)
end
